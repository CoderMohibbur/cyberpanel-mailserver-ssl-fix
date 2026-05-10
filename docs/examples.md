# Examples

## Check-only mode (default)
```bash
sudo bash scripts/cyberpanel-mail-ssl-fix.sh --host mail.example.com
```

## Apply safe fix mode
```bash
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

## Notes
- Keep all shared logs sanitized.
- Do not post real domains, private keys, mailbox passwords, or customer-specific data.
