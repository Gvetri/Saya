#!/usr/bin/env bash
# Saya — unpack a rack of knives onto this host.
#
#   scripts/unpack.sh <rack>            plan only (default): prints what would run
#   scripts/unpack.sh <rack> --apply    actually install
#
# A rack is a file in racks/<rack>.txt: one knife per line, `#` for comments.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RACKS_DIR="$REPO_DIR/racks"

RACK="${1:-}"
APPLY="false"
[ "${2:-}" = "--apply" ] && APPLY="true"

usage() {
  echo "usage: unpack.sh <rack> [--apply]"
  echo "racks:"
  ls "$RACKS_DIR" 2>/dev/null | sed 's/\.txt$//' | sed 's/^/  /'
  exit 2
}
[ -n "$RACK" ] || usage
RACK_FILE="$RACKS_DIR/$RACK.txt"
[ -f "$RACK_FILE" ] || { echo "no such rack: $RACK" >&2; usage; }

log()  { printf '%s\n' "$*"; }
step() { log "    \$ $*"; }
sh_()  { [ "$APPLY" = "true" ] && "$@" || return 0; }   # dry-run: print only

# ---- knives ----------------------------------------------------------------
# One small, idempotent installer per tool. Keep them short and readable.

knife_sdkman() {
  step "curl -sSL https://get.sdkman.io | bash"
  sh_ bash -c 'curl -sSL https://get.sdkman.io | bash'
}

knife_temurin_21() {
  local v="${TEMURIN_VERSION:-21.0.12-tem}"   # confirm with: sdk list java
  step "sdk install java $v && sdk default java $v"
  sh_ bash -c "source \"\$HOME/.sdkman/bin/sdkman-init.sh\"; sdk install java '$v' && sdk default java '$v'"
}

knife_android_cli() {
  local root="${ANDROID_HOME:-$HOME/Android/Sdk}"
  local url="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
  step "cmdline-tools -> $root/cmdline-tools/latest"
  step "sdkmanager --licenses ; sdkmanager platform-tools platforms;android-35 build-tools;35.0.0"
  sh_ bash -euo pipefail -c '
    root="$1"; url="$2"; tmp="$(mktemp -d)"
    mkdir -p "$root/cmdline-tools"
    curl -fsSL "$url" -o "$tmp/tools.zip"
    unzip -q "$tmp/tools.zip" -d "$tmp"
    rm -rf "$root/cmdline-tools/latest"
    mv "$tmp/cmdline-tools" "$root/cmdline-tools/latest"
    sm="$root/cmdline-tools/latest/bin/sdkmanager"
    yes | "$sm" --sdk_root="$root" --licenses >/dev/null
    "$sm" --sdk_root="$root" platform-tools "platforms;android-35" "build-tools;35.0.0"
    rm -rf "$tmp"
  ' _ "$root" "$url"
}

knife_maestro() {
  step "curl -Ls https://get.maestro.mobile.dev | bash"
  sh_ bash -c 'curl -Ls https://get.maestro.mobile.dev | bash'
}

# ---- runner ----------------------------------------------------------------
log "rack: $RACK  [$([ "$APPLY" = true ] && echo apply || echo plan)]"
log ""
while read -r line; do
  case "$line" in ''|\#*) continue;; esac
  fn="knife_${line//-/_}"
  declare -F "$fn" >/dev/null || { echo "! no installer for '$line'" >&2; exit 3; }
  log "-> $line"
  "$fn"
done < "$RACK_FILE"
log ""
[ "$APPLY" = true ] && log "done." || log "plan only — re-run with --apply to install."
