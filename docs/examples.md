# Examples

## Direct one-line check-only command
```bash
curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/scripts/cyberpanel-mail-ssl-fix.sh | sudo bash -s -- --host mail.example.com
```

## Direct one-line safe fix command
```bash
curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/scripts/cyberpanel-mail-ssl-fix.sh | sudo bash -s -- --host mail.example.com --fix
```

## Wget fallback command
```bash
(curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/scripts/cyberpanel-mail-ssl-fix.sh || wget -qO- https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/scripts/cyberpanel-mail-ssl-fix.sh) | sudo bash -s -- --host mail.example.com
```

## Optional install command
```bash
curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/install.sh | sudo bash
```

## Installed command usage
```bash
sudo cyberpanel-mailserver-ssl-fix --host mail.example.com
sudo cyberpanel-mailserver-ssl-fix --host mail.example.com --fix
```

## Inspect-before-run option
```bash
curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/scripts/cyberpanel-mail-ssl-fix.sh | less
```

## Manual local script usage
```bash
sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com
sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com --fix
```

## Use a custom map path
```bash
sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com --map /etc/postfix/vmail_ssl.map --fix
```

## Manual certificate verification
### Port 587 (STARTTLS)
```bash
openssl s_client -starttls smtp -connect mail.example.com:587 -servername mail.example.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

### Port 465 (SSL)
```bash
openssl s_client -connect mail.example.com:465 -servername mail.example.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

## Safe manual fix steps
```bash
sudo postmap -F hash:/etc/postfix/vmail_ssl.map
sudo systemctl restart postfix
sudo systemctl restart dovecot
```

## Why `bash` instead of `sh`
This project ships a Bash script and uses Bash-specific behavior and safety checks. Use `bash` (or `sudo bash`) instead of `sh` for reliable execution.

Note: if your repository uses a different default branch, replace `master` with your branch name.