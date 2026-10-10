#!/usr/bin/env bash
# Saya — unpack a rack of knives onto this host.
#
#   scripts/unpack.sh <rack>            plan only (default): prints what would run
#   scripts/unpack.sh <rack> --apply    actually install
#
# A rack is racks/<rack>.conf — a small shell file declaring `knives=(...)`.
# The shell is the parser: the rack is sourced, so there is no parser dependency
# and no parsing code here.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RACKS_DIR="$REPO_DIR/racks"

RACK="${1:-}"
APPLY="false"
[ "${2:-}" = "--apply" ] && APPLY="true"

usage() {
  echo "usage: unpack.sh <rack> [--apply]"
  echo "racks:"
  ls "$RACKS_DIR" 2>/dev/null | sed 's/\.conf$//' | sed 's/^/  /'
  exit 2
}
[ -n "$RACK" ] || usage
RACK_FILE="$RACKS_DIR/$RACK.conf"
[ -f "$RACK_FILE" ] || { echo "no such rack: $RACK" >&2; usage; }

log()  { printf '%s\n' "$*"; }
step() { log "    \$ $*"; }
sh_()  { [ "$APPLY" = "true" ] && "$@" || return 0; }   # dry-run: print only

# ---- the rack --------------------------------------------------------------
# Defaults — a rack may override any of these by declaring them.
knives=()
temurin_version="21.0.12-tem"
android_cmdline_tools="16111833"                                            # cmdline-tools 23.0
android_packages=(platform-tools platforms/android-35 build-tools/35.0.0)   # new Android CLI syntax

# shellcheck source=/dev/null
source "$RACK_FILE"

[ "${#knives[@]}" -gt 0 ] || { echo "rack '$RACK' declares no knives" >&2; exit 2; }

# ---- knives ----------------------------------------------------------------
# One small, idempotent installer per tool. Keep them short and readable.

knife_sdkman() {
  step "curl -sSL https://get.sdkman.io | bash"
  sh_ bash -c 'curl -sSL https://get.sdkman.io | bash'
}

knife_temurin_21() {
  step "sdk install java $temurin_version && sdk default java $temurin_version"
  sh_ bash -c "source \"\$HOME/.sdkman/bin/sdkman-init.sh\"; sdk install java '$temurin_version' && sdk default java '$temurin_version'"
}

knife_android_cli() {
  local root="${ANDROID_HOME:-$HOME/Android/Sdk}"
  local url="https://dl.google.com/android/repository/commandlinetools-linux-${android_cmdline_tools}_latest.zip"
  step "cmdline-tools ${android_cmdline_tools} -> $root/cmdline-tools/latest"
  step "android sdk install ${android_packages[*]}"
  sh_ bash -euo pipefail -c '
    root="$1"; url="$2"; shift 2; packages=("$@"); tmp="$(mktemp -d)"
    mkdir -p "$root/cmdline-tools"
    curl -fsSL "$url" -o "$tmp/tools.zip"
    unzip -q "$tmp/tools.zip" -d "$tmp"
    rm -rf "$root/cmdline-tools/latest"
    mv "$tmp/cmdline-tools" "$root/cmdline-tools/latest"
    android="$root/cmdline-tools/latest/bin/android"
    "$android" --sdk="$root" sdk install "${packages[@]}"
    rm -rf "$tmp"
  ' _ "$root" "$url" "${android_packages[@]}"
}

knife_maestro() {
  step "curl -Ls https://get.maestro.mobile.dev | bash"
  sh_ bash -c 'curl -Ls https://get.maestro.mobile.dev | bash'
}

# ---- runner ----------------------------------------------------------------
log "rack: $RACK  [$([ "$APPLY" = true ] && echo apply || echo plan)]"
log ""
for knife in "${knives[@]}"; do
  fn="knife_${knife//-/_}"
  declare -F "$fn" >/dev/null || { echo "! no installer for '$knife'" >&2; exit 3; }
  log "-> $knife"
  "$fn"
done
log ""
[ "$APPLY" = true ] && log "done." || log "plan only — re-run with --apply to install."
