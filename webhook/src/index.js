/**
 * Lakhsly OTA device registration webhook.
 *
 * The ONLY job of this worker is to relay the device UDID into the GitHub repo.
 * Everything else (Apple device registration, profile regeneration, rebuild,
 * hosting) is handled by GitHub Actions + GitHub Pages.
 *
 * Endpoints:
 *   GET  /udid            -> serves the .mobileconfig that captures the device UDID
 *   POST /capture         -> iOS callback after profile install; commits device to ota/devices.json
 *   GET  /api/status?udid -> registration + build status for the landing page
 *   GET  /api/devices     -> current registry (public; it is public in the repo anyway)
 *   GET  /                -> tiny health/info page
 */

const GH = "https://api.github.com";
const ACCEPT = "application/vnd.github+json";
const API_VERSION = "2022-11-28";

const headers = (token) => ({
  Authorization: `Bearer ${token}`,
  Accept: ACCEPT,
  "X-GitHub-Api-Version": API_VERSION,
});

const JSON_HEADERS = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

const DEVICE_PATH = (env) => `${env.REPO ? `${env.REPO}/` : ""}${env.DEVICES_PATH || "ota/devices.json"}`;

function json(res, code, body) {
  return new Response(JSON.stringify(body, null, 2), { status: code, headers: JSON_HEADERS });
}

function html(body, code = 200) {
  return new Response(body, { status: code, headers: { "Content-Type": "text/html; charset=utf-8" } });
}

function extractUdId(bodyText, contentType) {
  let fields = {};
  if (contentType && contentType.includes("application/json")) {
    try { fields = JSON.parse(bodyText); } catch { fields = {}; }
  } else {
    // iOS configurator profile POSTs form-urlencoded by default
    for (const pair of bodyText.split("&")) {
      const [k, v] = pair.split("=");
      if (k) fields[decodeURIComponent(k)] = decodeURIComponent((v || "").replace(/\+/g, " "));
    }
  }
  const udid = (fields.UDID || fields.udid || "").trim();
  const name = (fields.DEVICE_NAME || fields.name || "iPhone").trim();
  return { udid, name };
}

function validUdId(udid) {
  const bare = udid.replace(/-/g, "");
  return /^[0-9A-Fa-f]{16,40}$/.test(bare);
}

async function readDevices(env) {
  const url = `${GH}/repos/${env.OWNER}/${env.REPO}/contents/${env.DEVICES_PATH}`;
  const res = await fetch(url, { headers: headers(env.GITHUB_PAT) });
  if (res.status === 404) {
    return { sha: null, data: { cap: Number(env.CAP) || 15, devices: [] } };
  }
  if (!res.ok) throw new Error(`read devices failed: ${res.status} ${await res.text()}`);
  const meta = await res.json();
  const content = atob(meta.content);
  let data;
  try { data = JSON.parse(content); } catch { data = { cap: Number(env.CAP) || 15, devices: [] }; }
  return { sha: meta.sha, data };
}

async function writeDevices(env, sha, data) {
  const url = `${GH}/repos/${env.OWNER}/${env.REPO}/contents/${env.DEVICES_PATH}`;
  const body = { message: "ota: register device (webhook)", content: btoa(JSON.stringify(data, null, 2) + "\n") };
  if (sha) body.sha = sha;
  const res = await fetch(url, {
    method: "PUT",
    headers: { ...headers(env.GITHUB_PAT), "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`write devices failed: ${res.status} ${await res.text()}`);
  return res.json();
}

async function addDevice(env, udid, name) {
  // retry on concurrent-edit conflicts
  for (let attempt = 0; attempt < 6; attempt++) {
    const { sha, data } = await readDevices(env);
    const cap = Number(data.cap) || Number(env.CAP) || 15;
    const exists = data.devices.find((d) => d.udid === udid);
    if (exists) return { ok: true, existing: true, count: data.devices.length, cap };
    if (data.devices.length >= cap) return { ok: false, full: true, count: data.devices.length, cap };
    data.devices.push({ udid, name: name || "iPhone", at: new Date().toISOString(), status: "new" });
    try {
      await writeDevices(env, sha, data);
      return { ok: true, existing: false, count: data.devices.length, cap };
    } catch (e) {
      if (attempt === 5) throw e;
      // 409-style conflict -> loop and re-read
    }
  }
}

async function lastBuildInfo(env) {
  try {
    const res = await fetch(`https://${env.PAGES_URL}/build-info.json`, { cf: { cacheTtl: 0 } });
    if (!res.ok) return null;
    return await res.json();
  } catch {
    return null;
  }
}

const MOBILECONFIG = (baseUrl) => `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>PayloadType</key>
      <string>com.apple.configurator.profile</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>PayloadIdentifier</key>
      <string>com.anaranar.udid.content</string>
      <key>PayloadUUID</key>
      <string>E62B8E7A-6D0C-4C0B-9B1A-0A5A3C6F2D41</string>
      <key>PayloadDisplayName</key>
      <string>Lakhsly - Register this device</string>
      <key>PayloadDescription</key>
      <string>Identifies this device so Lakhsly can be installed on it.</string>
      <key>URL</key>
      <string>${baseUrl}/capture</string>
      <key>DeviceAttributes</key>
      <array>
        <string>UDID</string>
        <string>DEVICE_NAME</string>
        <string>PRODUCT_NAME</string>
        <string>PRODUCT_VERSION</string>
      </array>
    </dict>
  </array>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>PayloadIdentifier</key>
  <string>com.anaranar.udid.root</string>
  <key>PayloadUUID</key>
  <string>9F0E21B4-8C3D-4A52-B6E7-1F2C4D8E9A10</string>
  <key>PayloadDisplayName</key>
  <string>Lakhsly - Register this device</string>
</dict>
</plist>`;

const LANDING_AFTER_CAPTURE = (udid, pagesUrl) => `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Lakhsly - Registered</title>
<meta http-equiv="refresh" content="0; url=https://${pagesUrl}/?udid=${encodeURIComponent(udid)}">
</head>
<body style="font-family:sans-serif;background:#0f172a;color:#e2e8f0;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center">
<div><h1>Device registered</h1><p>Redirecting to the install page…</p></div>
</body></html>`;

const FALLBACK = `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Lakhsly OTA</title></head>
<body style="font-family:sans-serif;background:#0f172a;color:#e2e8f0;padding:2rem">
<h1>Lakhsly OTA registration service</h1>
<p>This endpoint relays device UDIDs into the Lakhsly build pipeline.</p>
<ul><li><a href="/udid" style="color:#38bdf8">/udid</a> - UDID capture profile</li>
<li><a href="/api/devices" style="color:#38bdf8">/api/devices</a> - registered devices</li></ul>
</body></html>`;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;
    const baseUrl = url.origin;
    const method = request.method;

    if (method === "OPTIONS") {
      return new Response("", { status: 204, headers: JSON_HEADERS });
    }

    if (!env.GITHUB_PAT) {
      return json({ error: "GITHUB_PAT secret not configured on this worker." }, 500, {});
    }

    try {
      if (path === "/udid" && method === "GET") {
        return new Response(MOBILECONFIG(baseUrl), {
          status: 200,
          headers: { "Content-Type": "application/x-apple-aspen-config" },
        });
      }

      if (path === "/capture" && method === "POST") {
        const bodyText = await request.text();
        const { udid, name } = extractUdId(bodyText, request.headers.get("Content-Type") || "");
        if (!validUdId(udid)) {
          return html("<h1>Invalid device identifier.</h1>", 400);
        }
        const result = await addDevice(env, udid.toUpperCase(), name);
        if (result.full) {
          return html("<h1>Registration full</h1><p>Lakhsly has reached its 15-device limit.</p>", 409);
        }
        return html(LANDING_AFTER_CAPTURE(udid.toUpperCase(), env.PAGES_URL));
      }

      if (path === "/api/status" && method === "GET") {
        const qUdId = (url.searchParams.get("udid") || "").trim().toUpperCase();
        const { data } = await readDevices(env);
        const cap = Number(data.cap) || Number(env.CAP) || 15;
        const device = data.devices.find((d) => d.udid === qUdId);
        const build = await lastBuildInfo(env);
        const registeredAt = device ? device.at : null;
        const lastBuildAt = build && build.builtAt ? build.builtAt : null;
        const canInstall =
          !!device && !!lastBuildAt && new Date(lastBuildAt).getTime() >= new Date(registeredAt).getTime();
        return json({
          count: data.devices.length,
          cap,
          registered: !!device,
          registeredAt,
          lastBuildAt,
          version: build ? build.version : null,
          canInstall,
        }, 200);
      }

      if (path === "/api/devices" && method === "GET") {
        const { data } = await readDevices(env);
        return json({ cap: data.cap, devices: data.devices }, 200);
      }

      if (path === "/" || path === "/health") {
        return html(FALLBACK);
      }

      return json({ error: "Not found" }, 404);
    } catch (e) {
      return json({ error: String(e && e.message ? e.message : e) }, 500);
    }
  },
};
