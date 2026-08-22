#!/usr/bin/env bash
#
# Registers devices from ota/devices.json with Apple (App Store Connect API)
# and regenerates ota/profile.mobileprovision (Ad Hoc, bundle com.anaranar.*).
#
# Env required:
#   ASC_P8         - contents of the App Store Connect API key (.p8, PKCS#8 EC P-256)
#   ASC_KEY_ID     - API key ID (kid)
#   ASC_ISSUER_ID  - team issuer ID (iss)
#
# Run from the repo root. Does NOT touch git - the workflow commits afterwards.
set -euo pipefail

: "${ASC_P8:?ASC_P8 (App Store Connect .p8 contents) is required}"
: "${ASC_KEY_ID:?ASC_KEY_ID is required}"
: "${ASC_ISSUER_ID:?ASC_ISSUER_ID is required}"

BASE="https://api.appstoreconnect.apple.com/v1"
DEVICES_JSON="ota/devices.json"
PROFILE_OUT="ota/profile.mobileprovision"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

printf '%s\n' "$ASC_P8" > "$TMP/key.p8"

# ---- Build ES256 JWT -------------------------------------------------------
now=$(date +%s)
exp=$((now + 1200))
HEADER=$(printf '{"alg":"ES256","kid":"%s","typ":"JWT"}' "$ASC_KEY_ID" | openssl base64 -A | tr '+/' '-_' | tr -d '=')
PAYLOAD=$(printf '{"iss":"%s","iat":%s,"exp":%s,"aud":"appstoreconnect-v1"}' "$ASC_ISSUER_ID" "$now" "$exp" | openssl base64 -A | tr '+/' '-_' | tr -d '=')
printf '%s' "$HEADER.$PAYLOAD" > "$TMP/sign.txt"
openssl dgst -sha256 -sign "$TMP/key.p8" -out "$TMP/sign.der" "$TMP/sign.txt"
python3 - "$TMP/sign.der" "$TMP/sign.raw" <<'PY'
import sys
b = open(sys.argv[1], "rb").read()
assert b[0] == 0x30
i = 1
l = b[i]; i += 1
if l & 0x80:
    n = l & 0x7F; i += n
def read_int():
    global i
    assert b[i] == 0x02; i += 1
    ln = b[i]; i += 1
    v = b[i:i+ln]; i += ln
    return v
r, s = read_int(), read_int()
def pad(x):
    x = x.lstrip(b"\x00")
    return (b"\x00" * (32 - len(x)) + x) if len(x) < 32 else x[-32:]
open(sys.argv[2], "wb").write(pad(r) + pad(s))
PY
SIG=$(openssl base64 -A -in "$TMP/sign.raw" | tr '+/' '-_' | tr -d '=')
JWT="$HEADER.$PAYLOAD.$SIG"
AUTH="Authorization: Bearer $JWT"

asc() { # method path [json-body]
  local m="$1" p="$2" b="${3:-}"
  if [ -n "$b" ]; then
    curl -sS -X "$m" -H "$AUTH" -H "Content-Type: application/json" -d "$b" "$BASE$p"
  else
    curl -sS -X "$m" -H "$AUTH" "$BASE$p"
  fi
}

# Skip when nothing new: all devices already registered and a profile exists.
if [ -f "$PROFILE_OUT" ] && ! python3 - <<'PY' | grep -q "^1$"
import json
d = json.load(open("ota/devices.json"))
print(1 if any(x.get("status") != "registered" for x in d.get("devices", [])) else 0)
PY
then
  echo "All devices already registered and profile exists - nothing to do."
  exit 0
fi

echo "== Distribution certificate =="
CERT_ID=$(asc GET "/certificates?filter[certificateType]=DISTRIBUTION" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['id'] if d.get('data') else '')")
[ -n "$CERT_ID" ] || { echo "ERROR: no DISTRIBUTION certificate found in team $ASC_ISSUER_ID" >&2; exit 1; }
echo "cert id: $CERT_ID"

echo "== Bundle ID (com.anaranar.*) =="
BUNDLE_ID=$(curl -sS -G -H "$AUTH" --data-urlencode "filter[identifier]=com.anaranar.*" "$BASE/bundleIds" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['id'] if d.get('data') else '')")
if [ -z "$BUNDLE_ID" ]; then
  BUNDLE_ID=$(asc GET "/bundleIds" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for b in d.get('data', []):
    if b['attributes']['identifier'].startswith('com.anaranar.'):
        print(b['id']); break
")
fi
[ -n "$BUNDLE_ID" ] || { echo "ERROR: bundle id com.anaranar.* not found in team" >&2; exit 1; }
echo "bundle id: $BUNDLE_ID"

echo "== Devices =="
python3 - "$TMP/devices_tsv" <<'PY'
import sys, json
d = json.load(open("ota/devices.json"))
with open(sys.argv[1], "w") as f:
    for dev in d.get("devices", []):
        f.write("%s\t%s\t%s\n" % (dev["udid"], dev.get("name") or "iPhone", dev.get("status") or "new"))
PY

: > "$TMP/device_ids"
count=0
while IFS=$'\t' read -r udid name status; do
  [ -n "$udid" ] || continue
  found=$(curl -sS -G -H "$AUTH" --data-urlencode "filter[udid]=$udid" "$BASE/devices")
  did=$(echo "$found" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['id'] if d.get('data') else '')")
  if [ -z "$did" ]; then
    body=$(python3 - "$udid" "$name" <<'PY'
import json, sys
print(json.dumps({"data":{"type":"devices","attributes":{"name":sys.argv[2],"platform":"IOS","udid":sys.argv[1]}}}))
PY
    )
    reg=$(asc POST "/devices" "$body")
    did=$(echo "$reg" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")
    echo "  registered new device $udid ($name) -> $did"
  else
    echo "  device exists $udid -> $did"
  fi
  echo "$did" >> "$TMP/device_ids"
  count=$((count + 1))
done < "$TMP/devices_tsv"

echo "== Provisioning profile =="
if [ "$count" -eq 0 ]; then
  echo "No devices registered - leaving existing profile untouched."
  exit 0
fi

python3 - "$TMP/device_ids" "$CERT_ID" "$BUNDLE_ID" "$TMP/profile_body.json" "$TMP/profile_name" <<'PY'
import json, sys
ids = [l.strip() for l in open(sys.argv[1]) if l.strip()]
body = {
  "data": {
    "type": "profiles",
    "attributes": {"name": "export_anar", "profileType": "IOS_APP_ADHOC"},
    "relationships": {
      "bundleId": {"data": {"type": "bundleIds", "id": sys.argv[3]}},
      "certificates": {"data": [{"type": "certificates", "id": sys.argv[2]}]},
      "devices": {"data": [{"type": "devices", "id": d} for d in ids]},
    },
  }
}
json.dump(body, open(sys.argv[4], "w"))
open(sys.argv[5], "w").write(body["data"]["attributes"]["name"])
PY

for old in $(curl -sS -G -H "$AUTH" --data-urlencode "filter[name]=export_anar" "$BASE/profiles" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(' '.join(p['id'] for p in d.get('data', [])))
"); do
  curl -sS -X DELETE -H "$AUTH" "$BASE/profiles/$old" > /dev/null || true
  echo "  removed previous profile $old"
done

PROF_NAME=$(cat "$TMP/profile_name")
PROF=$(asc POST "/profiles" "$(cat "$TMP/profile_body.json")")
PROF_CONTENT=$(echo "$PROF" | python3 -c "
import sys, json
d = json.load(sys.stdin)
a = d['data']['attributes']
print(a['profileContent'])
" | tr -d '\n')
[ -n "$PROF_CONTENT" ] || { echo "ERROR: profile creation failed: $PROF" >&2; exit 1; }
printf '%s' "$PROF_CONTENT" | base64 --decode > "$PROFILE_OUT"
echo "profile $PROF_NAME written to $PROFILE_OUT ($(wc -c < "$PROFILE_OUT") bytes)"

echo "== Mark devices registered =="
python3 - <<'PY'
import json
d = json.load(open("ota/devices.json"))
for dev in d.get("devices", []):
    dev["status"] = "registered"
json.dump(d, open("ota/devices.json", "w"), indent=2)
PY

echo "DONE"
