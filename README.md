# CyberPanel MailServer SSL Fix

Fixes a common CyberPanel mail SSL issue where SMTP over TLS/SSL fails even though CyberPanel reports that MailServer SSL was renewed or issued.

## Why this repository exists
In some CyberPanel environments, the Let's Encrypt certificate files are renewed on disk, but Postfix and Dovecot continue serving an older certificate for SMTP clients. This can cause Gmail, Outlook, and Thunderbird to reject or warn on TLS/SSL connections.

This repository provides:
- Safe, production-friendly troubleshooting steps
- A conservative helper script for check-only diagnostics and an optional safe fix path
- Public-safe documentation with sanitized examples only

## Typical symptoms
- Gmail SMTP setup fails
- Outlook/Thunderbird shows certificate warning
- Port 25 may work but 587 TLS or 465 SSL fails
- `openssl` shows expired certificate on SMTP ports
- CyberPanel MailServer SSL page says renewed/issued

## Root cause
CyberPanel may renew the Let's Encrypt certificate on disk, but Postfix/Dovecot can continue serving the old certificate until the Postfix SSL map is rebuilt and mail services are restarted.

## Quick manual fix
```bash
sudo postmap -F hash:/etc/postfix/vmail_ssl.map
sudo systemctl restart postfix
sudo systemctl restart dovecot
```

## Manual verification commands
For `587 STARTTLS`:
```bash
openssl s_client -starttls smtp -connect mail.example.com:587 -servername mail.example.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

For `465 SSL`:
```bash
openssl s_client -connect mail.example.com:465 -servername mail.example.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

## Script usage
Check only:
```bash
sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com
```

Apply safe fix:
```bash
sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com --fix
```

## Gmail recommended settings
- SMTP Server: `mail.example.com`
- Port: `587`
- Security: `TLS`
- Username: full email address
- Password: mailbox password

Alternative:
- Port: `465`
- Security: `SSL`

## Safety notes
This helper script is intentionally conservative:
- Does not edit Postfix or Dovecot config files
- Does not delete certificates
- Does not run package updates
- Does not reboot the server
- Does not change DNS

## Troubleshooting
- `vmail_ssl.map not found`:
  Use the `--map` option if your map path is custom, and verify Postfix TLS SNI map configuration.
- Certificate still old after fix:
  Re-run cert checks on ports 587 and 465, then inspect service logs and confirm the expected certificate files are referenced by your map entries.
- Gmail still fails after cert is valid:
  Verify account auth details, SMTP auth status, and mailbox provider-side restrictions.
- Wrong mailbox password:
  Confirm mailbox credentials in CyberPanel and retry SMTP authentication.
- SMTP authentication issue:
  Validate SMTP AUTH is enabled and check Postfix/Dovecot auth logs.
- Firewall or rate-limit:
  Confirm ports 587/465 are reachable from client networks and not throttled.
- DNS/hostname mismatch:
  Ensure client uses the same hostname present in certificate SANs (for example `mail.example.com`).

## Example before/after output (sanitized)
Before fix (`mail.example.com:587`):
```text
subject=CN = mail.example.com
issuer=C = US, O = Let's Encrypt, CN = R3
notBefore=Jan 01 00:00:00 2024 GMT
notAfter=Mar 31 23:59:59 2024 GMT
X509v3 Subject Alternative Name:
    DNS:mail.example.com
```

After fix (`mail.example.com:587`):
```text
subject=CN = mail.example.com
issuer=C = US, O = Let's Encrypt, CN = E6
notBefore=May 01 00:00:00 2026 GMT
notAfter=Jul 30 23:59:59 2026 GMT
X509v3 Subject Alternative Name:
    DNS:mail.example.com
```

## Repository structure
```text
README.md
LICENSE
SECURITY.md
CONTRIBUTING.md
CHANGELOG.md
.gitignore
scripts/cyberpanel-mail-ssl-fix.sh
docs/examples.md
docs/case-study.md
docs/github-publishing-guide.md
.github/ISSUE_TEMPLATE/bug_report.md
.github/ISSUE_TEMPLATE/troubleshooting_help.md
```
