# Lakhsly OTA - one-time setup (you do these steps)

This folder is the whole self-service install pipeline:

- `devices.json` - registry of registered UDIDs (cap 15). The webhook appends here.
- `profile.mobileprovision` - Ad Hoc profile covering ALL registered devices. Regenerated
  automatically by `tool/asc_register.sh` whenever a new device registers.
- `../webhook/` - a tiny Cloudflare Worker. It is the ONLY receiver for the UDID capture
  profile; it writes new devices into `devices.json` via the GitHub API.

Do the steps below **once**, in order. Everything after that is automatic.

---

## 1. Create an App Store Connect API key

This lets GitHub Actions register devices + regenerate the Ad Hoc profile for you.

1. Go to https://appstoreconnect.apple.com/access/integrations
2. Click the **+** button → **App Store Connect API**.
3. Give it a name (e.g. `lakhsly-ota`) and access level **App Manager** (or Admin).
4. Click **Generate API Key**. You'll get:
   - **Key ID** (10 chars, e.g. `ABCDEF1234`)
   - **Issuer ID** (UUID, e.g. `69a6de93-...-9c3a`)
   - A **`.p8`** download. **Download it now** - you can't download it again.
5. Keep the `.p8` (it's the `ASC_P8` secret value). Never commit it.

## 2. Create a GitHub classic PAT (personal access token)

The Worker and the register-device job need a token that can write to this repo.

1. https://github.com/settings/tokens → **Generate new token** → **Generate new token (classic)**.
2. Give it a name (e.g. `lakhsly-ota`), expiration e.g. 1 year.
3. Select scopes: **`repo`** (full) and **`workflow`**.
4. **Generate token** and copy it (shown only once).

## 3. Deploy the Worker

Run from the repo root (needs Node.js, and a free Cloudflare account):

```bash
cd webhook
npm install
npx wrangler login
npx wrangler secret put GITHUB_PAT     # paste the PAT from step 2
npx wrangler deploy
```

Note the deployed URL, e.g. `https://lakhsly-ota.your-subdomain.workers.dev`.
Check it: `https://lakhsly-ota.your-subdomain.workers.dev/health`.

## 4. Add repository secrets

https://github.com/abdelrhmanezzat1/lkhaslyv.2/settings/secrets/actions → **New repository secret**:

| Name | Value |
|---|---|
| `SIGNING_CERTIFICATE_P12` | base64 of `export_anar.p12` (PowerShell: `certutil -encode sigin\iOS_Development_Certificates\export_anar.p12 p12.b64` then paste, remove header/footer lines) |
| `SIGNING_CERTIFICATE_P12_PASSWORD` | `1234` |
| `ASC_P8` | full contents of the `.p8` file from step 1 (copy the whole file text) |
| `ASC_KEY_ID` | Key ID from step 1 |
| `ASC_ISSUER_ID` | Issuer ID from step 1 |
| `GH_DISPATCH_TOKEN` | the PAT from step 2 |
| `WORKER_URL` | your Worker URL from step 3, e.g. `https://lakhsly-ota.your-subdomain.workers.dev` |

## 5. Enable GitHub Pages (Actions source)

1. https://github.com/abdelrhmanezzat1/lkhaslyv.2/settings/pages
2. **Source**: `GitHub Actions`.
3. (Leave the URL as `https://abdelrhmanezzat1.github.io/lkhaslyv.2`.)

## 6. First build

Go to **Actions** → **Build iOS IPA (Signed + OTA)** → **Run workflow** (on `main`).

The `build` job will sign with the Ad Hoc profile in `ota/profile.mobileprovision`; the
`publish-ota` job will then publish the install page.

## 7. Give out the install link

Landing page: `https://abdelrhmanezzat1.github.io/lkhaslyv.2/`

How a new tester installs:

1. Opens the link in **Safari** on their iPhone.
2. Taps **Install Device Profile**, approves, installs it (Settings → Profile Downloaded).
   This only captures the UDID - it is not a management profile.
3. They land back on the page showing **"Registered - building…"** (~10 min).
4. When the page flips to the blue **Install Lakhsly** button, they tap it.

The pipeline registers the device with Apple and rebuilds automatically (cron every
10 minutes picks up new registrations). The registry is capped at **15 devices**.

## Notes / renewal

- Ad Hoc profile + cert expire **2026-10-29**. Before that date: log into the Jakia Hajna
  account (team `4Z7V3V3G9R`), renew the Distribution certificate, export a new `.p12`,
  update `SIGNING_CERTIFICATE_P12` + `SIGNING_CERTIFICATE_P12_PASSWORD`.
- UDIDs in this repo are already public via the IPA; nothing sensitive lives here.
- `sigin/` stays out of git (`.gitignore`). The `.p8`, `.p12` and PAT must never be committed.
