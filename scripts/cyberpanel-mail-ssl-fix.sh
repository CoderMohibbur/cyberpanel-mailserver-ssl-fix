#!/usr/bin/env bash

# Safe helper for diagnosing and fixing stale SMTP certificates on CyberPanel mail servers.
# Default mode is check-only; fix mode requires explicit --fix and root privileges.

set -u
set -o pipefail

MAP_PATH="/etc/postfix/vmail_ssl.map"
HOST=""
DO_FIX=0

print_help() {
  cat <<'EOF'
Usage:
  cyberpanel-mail-ssl-fix.sh --host HOSTNAME [--fix] [--map /etc/postfix/vmail_ssl.map]

Options:
  --host HOSTNAME   Required mail hostname (example: mail.example.com)
  --fix             Apply safe fix: rebuild Postfix SSL map and restart postfix/dovecot
  --map PATH        Optional map path (default: /etc/postfix/vmail_ssl.map)
  -h, --help        Show this help

Examples:
  sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com
  sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com --fix
EOF
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

show_cert() {
  local host="$1"
  local port="$2"
  local mode="$3"
  local label="$4"

  log ""
  log "== $label ($host:$port) =="

  if [[ "$mode" == "starttls" ]]; then
    if openssl s_client -starttls smtp -connect "${host}:${port}" -servername "$host" </dev/null 2>/dev/null \
      | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null; then
      return 0
    fi
  else
    if openssl s_client -connect "${host}:${port}" -servername "$host" </dev/null 2>/dev/null \
      | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null; then
      return 0
    fi
  fi

  warn "Could not read certificate from ${host}:${port}. Check DNS, firewall, service status, and hostname."
}

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    fail "--fix requires root. Re-run with sudo."
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      shift
      [[ $# -gt 0 ]] || fail "Missing value for --host"
      HOST="$1"
      ;;
    --fix)
      DO_FIX=1
      ;;
    --map)
      shift
      [[ $# -gt 0 ]] || fail "Missing value for --map"
      MAP_PATH="$1"
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
  shift
done

if [[ -z "$HOST" ]]; then
  print_help
  fail "--host is required"
fi

log "CyberPanel MailServer SSL helper"
log "Host: $HOST"
log "Map:  $MAP_PATH"
log "Mode: $([[ "$DO_FIX" -eq 1 ]] && echo "fix" || echo "check-only")"

show_cert "$HOST" 587 starttls "SMTP STARTTLS"
show_cert "$HOST" 465 ssl "SMTP SSL"

log ""
if [[ -f "$MAP_PATH" ]]; then
  log "Map file exists:"
  ls -l "$MAP_PATH"
else
  warn "Map file not found: $MAP_PATH"
fi

if [[ "$DO_FIX" -eq 0 ]]; then
  log ""
  log "Check-only mode complete."
  log "To apply the safe fix, run:"
  log "  sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host $HOST --fix"
  if [[ "$MAP_PATH" != "/etc/postfix/vmail_ssl.map" ]]; then
    log "  (custom map path currently set with --map '$MAP_PATH')"
  fi
  exit 0
fi

require_root

[[ -f "$MAP_PATH" ]] || fail "Required map file not found: $MAP_PATH"
command -v postmap >/dev/null 2>&1 || fail "Required command not found: postmap"
command -v systemctl >/dev/null 2>&1 || fail "Required command not found: systemctl"

log ""
log "Running safe fix steps..."
log "1) Rebuild Postfix SSL map"
postmap -F "hash:${MAP_PATH}" || fail "postmap failed"

log "2) Restart postfix"
systemctl restart postfix || fail "Failed to restart postfix"

log "3) Restart dovecot"
systemctl restart dovecot || fail "Failed to restart dovecot"

log "4) Waiting 3 seconds"
sleep 3

log ""
log "Post-fix certificate verification:"
show_cert "$HOST" 587 starttls "SMTP STARTTLS (after fix)"
show_cert "$HOST" 465 ssl "SMTP SSL (after fix)"

log ""
log "Done. If the certificate is still old, review map entries and service logs."
