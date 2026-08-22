# ─────────────────────────────────────────────────────────────────────────────
# tool/lint.ps1 — PowerShell equivalent of tool/lint.sh for Windows
# ─────────────────────────────────────────────────────────────────────────────
[CmdletBinding()]
param(
  [switch]$Fix
)

$ErrorActionPreference = 'Stop'
Set-Location -Path (Split-Path -Parent $PSScriptRoot)

function Step($msg) { Write-Host "`e[1;34m▶ $msg`e[0m" }
function Ok($msg)   { Write-Host "`e[1;32m✔ $msg`e[0m" }
function Die($msg)  { Write-Host "`e[1;31m✘ $msg`e[0m"; exit 1 }

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) { Die "flutter not found on PATH" }

try {
  Step "1/4  flutter pub get"
  flutter pub get

  Step "2/4  build_runner build"
  dart run build_runner build --delete-conflicting-outputs

  Step "3/4  analyzer (fatal infos + fatal warnings)"
  flutter analyze --fatal-infos --fatal-warnings

  Step "4/4  formatter check"
  if ($Fix) {
    dart format lib test
  } else {
    dart format --set-exit-if-changed --output=none lib test
  }
  Ok "all checks passed"
} catch {
  Die $_.Exception.Message
}
