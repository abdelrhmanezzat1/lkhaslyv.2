# Lakhsly iOS Signing Migration Plan — Fresh Setup

**Status:** cutover edits applied locally 2026-10-16 — no commits, no remote CI secrets changed, no signing build run.
**Bundle ID (changed with approval):** `app.jujube1760.cassava8287` (was `com.anaranar.lkhsly`) — changed 2026-10-16 by explicit user approval so it matches the new DxSign profile's App ID. Firebase iOS app registration must be updated to match (see Decision log).
**New signing team:** `9FTBM39AHP` (DxSign provider profile, Ad Hoc, expires 2027-10-13).
**Last audited:** 2026-10-16 (read-only audit of all CI/build references).

> **Scope note:** this plan removes old signing assets from the project's *future*
> signing and build inputs. It makes **no claim** that any old certificate or
> provisioning profile has been revoked, deleted, or erased from any remote
> Apple or provider account.

---

## 1. Hard rules for the migration

1. **No reuse** of any existing signing certificate, private key, provisioning
   profile, or certificate archive — including `export_anar.p12`, the Codemagic
   / GitHub secrets that hold it, and everything under `_quarantine/`.
2. **`ota/profile.mobileprovision` (expires 2026-10-29T16:56:59Z) is excluded**
   from all future signing and build inputs. It must not be installed into any
   keychain/profile directory, published to the OTA site, regenerated, or
   committed again.
3. **Harley-Davidson artifacts are forbidden** in every Lakhsly workflow
   (`_quarantine/unrelated-signing/*`: foreign team `TVA2HSAF7X`, App ID
   `com.harley-davidson.event`). They stay quarantined and ignored.
4. **No device carry-over.** The three previously intended iPhones
   (`00008030-00064CAE2642802E`, `00008110-00022CA21440401E`,
   `00008130-000A1C5A1043401C`) are **not** preserved, registered, or carried
   into the new plan. Any device list starts empty and is populated only for
   devices the new signing method actually needs.
5. **Bundle ID:** originally locked to `com.anaranar.lkhsly`; **changed to
   `app.jujube1760.cassava8287` on 2026-10-16 with explicit user approval**
   because the new DxSign profile's explicit App ID could not cover the old ID.
   Firebase `.env` keys (`FIREBASE_IOS_BUNDLE_ID`) and any Firebase console app
   registration must be updated to the new ID (user-side follow-up).
6. **Fresh assets only** — everything comes from the selected signing provider
   (new `.p12` + private key, new provisioning profile, matching team).
7. **Capabilities preserved** — see §4.
8. Nothing is purchased, deleted permanently, committed, stashed, reset, or
   discarded as part of this plan.

---

## 2. Audit: every reference to the old profile and certificate secrets

| # | Location | What it references | Proposed change (smallest necessary) |
|---|---|---|---|
| 1 | `codemagic.yaml:5-6` | comments naming `export_anar.p12` and its password | delete the two comment lines (password must not live in the repo) |
| 2 | `codemagic.yaml:67-93` | `SIGNING_CERTIFICATE_P12` import + reads `ota/profile.mobileprovision` | profile path → `signing/profile.mobileprovision`; keep secret *names* (values live in CI, we never touch them) but signing stays disabled/unsigned until fresh assets exist |
| 3 | `codemagic.yaml:121` | ExportOptions `teamID = 4Z7V3V3G9R` | replace with new team ID **after provider selection** (placeholder until then) |
| 4 | `.github/workflows/build-ios.yml:48,52,185-189` | commits + installs `ota/profile.mobileprovision` | same profile-path change; stop committing any profile |
| 5 | `.github/workflows/build-ios.yml:171-195` | `SIGNING_CERTIFICATE_P12` / `_PASSWORD` import | keep mechanism, invalidate old value by rotating the secret **later, by you** — this plan does not modify remote secrets |
| 6 | `.github/workflows/build-ios.yml:213` | ExportOptions `teamID = 4Z7V3V3G9R` | same as #3 |
| 7 | `.github/workflows/build-ios.yml:27-65` (`register-devices` job) | runs `tool/asc_register.sh`, regenerates the old `export_anar` profile, commits it | **disable the job** — it manufactures excluded asset #2; rewrite only if the new provider supports ASC API automation |
| 8 | `.github/workflows/build-ios.yml:293` | publishes old profile to OTA site | remove the copy line (profile is not an app-install input) |
| 9 | `.github/workflows/ota-deploy.yml:62` | publishes old profile to OTA site | remove the copy line |
| 10 | `tool/asc_register.sh:4,20,142,154` | regenerates `ota/profile.mobileprovision`, name `export_anar`, old team | mark obsolete; keep file (no deletion) until rewritten for the new team |
| 11 | `.gitignore:67` | `!ota/profile.mobileprovision` exception | remove the exception (untracking the file itself needs a commit → separate approval) |
| 12 | `ios/Runner.xcodeproj/project.pbxproj:386,572,601` | `DEVELOPMENT_TEAM = 4Z7V3V3G9R` (Debug/Profile/Release) | replace with new team ID once provider confirms it — **ask first** |
| 13 | `ios/Runner.xcodeproj/project.pbxproj:398,584,613` | `PROVISIONING_PROFILE_SPECIFIER = "export_anar"` (×3) | set to the new profile's name once it exists, or clear specifier and rely on CI ExportOptions |
| 14 | `ota/SETUP.md:21-30,78-79,96,117-118` | old team, old `.p12`, its password, the three UDIDs, renewal instructions for expired assets | rewrite after the new setup works; until then treat as historical |
| 15 | `ota/devices.json:4-6` | the three old UDIDs | reset to an empty registry when the new signing method needs one; old UDIDs do not carry over |
| 16 | `github/workflows/build-ios.yml` (non-hidden duplicate) | dead file, unsigned build only, no old-asset refs | leave untouched (approved previously) |

No Harley-Davidson or `certificates (1).zip` references exist anywhere outside
`_quarantine/`.

---

## 3. Fresh signing setup (when the provider is selected)

Prerequisites checklist — all must come from the **new** provider, none reused:

- [ ] New Apple Developer team ID (record it; replace references #3, #6, #12).
- [ ] New distribution certificate + private key delivered as a `.p12` (or
      provider-equivalent) — **you** import it into Codemagic/GitHub secrets;
      never commit it (`.gitignore` already blocks `*.p12`).
- [ ] New secret *value* rotation for `SIGNING_CERTIFICATE_P12` /
      `SIGNING_CERTIFICATE_P12_PASSWORD` (names unchanged so workflows keep
      working; the old values must stop being valid inputs — done by you in the
      CI secret store, not by this repo).
- [ ] New provisioning profile for App ID covering `com.anaranar.lkhsly`,
      saved as `signing/profile.mobileprovision` (new directory, gitignored),
      **not** at `ota/profile.mobileprovision`.
- [ ] Profile type matches distribution goal (Ad Hoc → new device list from
      scratch; the old three UDIDs are not migrated).
- [ ] Cert and profile belong to the **same** team — verified by comparing the
      profile's `TeamIdentifier` against the cert's OU before first build.
- [ ] ExportOptions team IDs (#3, #6) and pbxproj team (#12) updated to match.
- [ ] Bundle ID in ExportOptions stays `com.anaranar.lkhsly`.

Local Windows host cannot run `codesign`/`xcodebuild`; signature verification
happens only on the macOS CI runner (Codemagic or GitHub `macos-*`).

---

## 4. Capabilities to preserve (verify on the new profile before first release)

| Capability | Why the app needs it | Where it lives today |
|---|---|---|
| **Push Notifications (`aps-environment`)** | `firebase_messaging`, `UIBackgroundModes: remote-notification` | profile entitlement — **note:** the old profile did **not** include it; confirm the new provider's method supports it, otherwise push silently fails |
| **Keychain Sharing** | team keychain group (`<TEAM>.*`) used by `shared_preferences`/plugin stores | profile entitlement |
| **Data Protection** | `com.apple.developer.default-data-protection = NSFileProtectionComplete` | profile entitlement |
| Location privacy strings | `NSLocationWhenInUse` / `NSLocationAlwaysAndWhenInUseUsageDescription` | `ios/Runner/Info.plist` (no entitlement; keep as-is) |
| Bundle ID `com.anaranar.lkhsly` | Firebase iOS app, OTA manifest, Supabase | `project.pbxproj`, `.env`, `ota/manifest.plist` |

Rules: never drop an entitlement merely to make verification pass; re-check the
new profile against this table before publishing. Capabilities present in the
*old* profile but unused by the app (Siri, Network Extensions, iCloud
kvstore, Pass Types) are **not** required and need not be requested again.

---

## 5. Sequencing

1. ✅ Read-only audit of all references (§2).
2. ✅ User approved the CI edits and the bundle-ID change (2026-10-16).
3. ✅ Applied repo-side edits: `codemagic.yaml`, both workflow files,
   `.gitignore`, pbxproj (bundle/team/profile specifier), OTA manifest +
   build-info bundle ID.
4. ✅ `register-devices` job disabled (`if: false`); `tool/asc_register.sh`
   banner-marked obsolete.
5. ⬜ **You:** rotate CI secrets — `SIGNING_CERTIFICATE_P12` (base64 of the new
   `00008130-000A1C5A1043401C.p12`) and `SIGNING_CERTIFICATE_P12_PASSWORD`
   (from the provider readme) in Codemagic **and** GitHub Actions. Until then a
   signed build will fail (old secret + new profile mismatch) — expected.
6. ⬜ **You:** update Firebase — register iOS app `app.jujube1760.cassava8287`
   and refresh `FIREBASE_IOS_*` values in `.env` / CI secrets; configure the
   APNs auth key for push under the new team's provider account.
7. ⬜ Commit the new profile (`00008130-000A1C5A1043401C/*.mobileprovision` is
   un-ignored for this purpose; `readme.txt` and `*.p12` stay ignored) — needs
   explicit commit approval.
8. ⬜ First build on macOS CI → validate: `codesign --verify --deep --strict`,
   entitlement dump against §4 (aps-environment, keychain), profile expiry.
9. ⬜ Rewrite `ota/SETUP.md` fully; untrack `ota/profile.mobileprovision`
   (separate commit approval).

## 6. Known limitations

- **Verification gap:** this machine is Windows; no Apple signing tools exist
  here. Any "installable" claim requires an actual signed build + device check
  on CI.
- **Remote state untouched:** old certificates/profiles may still exist in
  Apple/provider accounts; this plan only excludes them from project inputs and
  makes no revocation or deletion claims.
- **Push:** profile entitlement `aps-environment = production` is present
  (verified 2026-10-16); actual delivery also needs the APNs auth key
  configured by the provider/user in Firebase — outside this repo.
- **Device coverage:** the new profile provisions exactly 1 device; other
  devices cannot install until the provider adds their UDIDs.
- **Uncommitted work:** the repo has pre-existing unrelated changes on branch
  `cleanup/unrelated-signing-quarantine`; all future commits (including the new
  profile and any untracking of the old one) need explicit approval and must
  not sweep those changes in.

## 7. Decision & execution log

- **2026-10-16 — bundle ID change approved.** User instruction: "you can change
  bundle id for app to same [DxSign] files". Executed: iOS bundle ID
  `com.anaranar.lkhsly` → `app.jujube1760.cassava8287` (pbxproj ×3, Codemagic
  and GitHub ExportOptions keys, `ota/manifest.plist`, `ota/build-info.json`).
  Rationale: new profile's explicit App ID `9FTBM39AHP.app.jujube1760.cassava8287`
  cannot cover the old ID (compatibility check FAIL #6 in the DxSign audit).
- **Same date — cutover applied:** team `4Z7V3V3G9R` → `9FTBM39AHP` (pbxproj ×3,
  both ExportOptions); profile specifier `export_anar` →
  `00008130-000A1C5A1043401CGL3AAH`; CI profile paths →
  `00008130-000A1C5A1043401C/00008130-000A1C5A1043401C.mobileprovision`;
  `register-devices` disabled; old-profile publishing removed from
  `build-ios.yml` + `ota-deploy.yml`; `.gitignore` exception swapped to the new
  profile + added ignore for the password `readme.txt`; obsolete banners on
  `tool/asc_register.sh` and `ota/SETUP.md`.
- **Untouched by design:** RunnerTests bundle IDs (awaiting confirmation),
  `ota/devices.json` (user data), Android `applicationId` (`com.lakhsly.app`,
  different platform), `.env` (user-managed secrets), webhook UDID-capture
  payload IDs, all signing binaries (no copy/rename/delete), no commits, no
  remote secret changes, no signing build.
- **2026-10-16 (later) — OTA repair (Phase D).** Verified GitHub Pages source
  = `gh-pages` branch (`gh api .../pages`), so Codemagic's branch push is the
  live publisher; `ota-deploy.yml`/`publish-ota` Actions deploys target a
  non-live slot. Fixed: Codemagic now publishes the COMPLETE rendered site
  (IPA + version-stamped manifest + build-info + honest static install page)
  instead of the IPA only (which left the live manifest stale at
  `com.anaranar.lkhsly`/1.0.0); added bundle-ID + version guards to all three
  publish paths so a wrong/stale IPA can never overwrite the live site;
  replaced the worker/UDID-registration install page with a static honest page
  ("registered devices only") since `register-devices` is disabled; removed the
  dead ota-deploy dispatch from Codemagic and stopped publishing `devices.json`
  (public UDID exposure). Decision pending for owner: keep branch source
  (Codemagic publishes) or switch Pages to GitHub Actions and re-enable
  Actions-based publishing.
