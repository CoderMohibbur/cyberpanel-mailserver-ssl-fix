#!/usr/bin/env bash

set -euo pipefail

OWNER="CoderMohibbur"
REPO="cyberpanel-mailserver-ssl-fix"
DEFAULT_BRANCH="master"
BRANCH="$DEFAULT_BRANCH"
PREFIX="/usr/local/sbin"
TARGET_NAME="cyberpanel-mailserver-ssl-fix"
UNINSTALL=0

usage() {
  cat <<EOF
Usage:
  install.sh [--prefix /usr/local/sbin] [--branch master] [--uninstall] [--help]

Options:
  --prefix PATH    Install directory prefix (default: /usr/local/sbin)
  --branch NAME    GitHub branch for download (default: $DEFAULT_BRANCH)
  --uninstall      Remove installed command only
  -h, --help       Show this help

This installer:
- Downloads only scripts/cyberpanel-mail-ssl-fix.sh from this repository
- Validates syntax with bash -n before install
- Installs command as: /usr/local/sbin/cyberpanel-mailserver-ssl-fix (or custom --prefix)
EOF
}

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    fail "This action requires root. Re-run with sudo."
  fi
}

download() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url"
    return
  fi

  fail "Neither curl nor wget is available."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      shift
      [[ $# -gt 0 ]] || fail "Missing value for --prefix"
      PREFIX="$1"
      ;;
    --branch)
      shift
      [[ $# -gt 0 ]] || fail "Missing value for --branch"
      BRANCH="$1"
      ;;
    --uninstall)
      UNINSTALL=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
  shift
done

TARGET_PATH="$PREFIX/$TARGET_NAME"
RAW_URL="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/scripts/cyberpanel-mail-ssl-fix.sh"

if [[ "$UNINSTALL" -eq 1 ]]; then
  require_root
  if [[ -e "$TARGET_PATH" ]]; then
    rm -f -- "$TARGET_PATH"
    log "Removed: $TARGET_PATH"
  else
    log "Not installed: $TARGET_PATH"
  fi
  exit 0
fi

require_root
mkdir -p -- "$PREFIX"

TMP_FILE="$(mktemp)"
cleanup() {
  rm -f -- "$TMP_FILE"
}
trap cleanup EXIT

log "Downloading helper script from: $RAW_URL"
download "$RAW_URL" "$TMP_FILE"

bash -n "$TMP_FILE" || fail "Downloaded script failed bash syntax check."
install -m 0755 "$TMP_FILE" "$TARGET_PATH"

log "Installed command: $TARGET_PATH"
log ""
log "Usage examples:"
log "  sudo $TARGET_NAME --host mail.example.com"
log "  sudo $TARGET_NAME --host mail.example.com --fix"
log ""
log "Safety notes:"
log "- Does not edit Postfix/Dovecot config files"
log "- Does not delete certificates"
log "- Does not run package updates"
log "- Does not reboot or change DNS"