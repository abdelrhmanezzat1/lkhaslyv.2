#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# tool/lint.sh — CI-style local lint gate for the CarServices Flutter app.
#
# Mirrors the rules the CI pipeline runs so contributors catch regressions
# before pushing. Requires Flutter ≥ 3.16 on PATH.
#
# Usage:
#   ./tool/lint.sh            # runs analyzer + format check + code generation
#   ./tool/lint.sh --fix      # applies `dart fix` and `dart format` automatically
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FIX=0
if [[ "${1:-}" == "--fix" ]]; then
  FIX=1
fi

step() { printf "\033[1;34m▶ %s\033[0m\n" "$1"; }
ok()   { printf "\033[1;32m✔ %s\033[0m\n" "$1"; }
die()  { printf "\033[1;31m✘ %s\033[0m\n" "$1"; exit 1; }

command -v flutter >/dev/null 2>&1 || die "flutter not found on PATH"

step "1/4  flutter pub get"
flutter pub get

step "2/4  build_runner build (delete-conflicting-outputs)"
dart run build_runner build --delete-conflicting-outputs

step "3/4  analyzer (fatal infos + fatal warnings)"
flutter analyze --fatal-infos --fatal-warnings

step "4/4  formatter check"
if [[ "$FIX" -eq 1 ]]; then
  dart format lib test
else
  dart format --set-exit-if-changed --output=none lib test
fi

ok "all checks passed"
