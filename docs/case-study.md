# Case Study (Sanitized)

## Scenario
A CyberPanel mail server showed successful MailServer SSL renewal in the panel, but users could not complete SMTP setup in Gmail and saw certificate warnings in desktop clients.

## Before fix
- SMTP on port 587/465 returned an expired certificate for `mail.example.com`.
- CyberPanel UI indicated the SSL renewal had completed.

Example (sanitized):
```text
notAfter=Mar 31 23:59:59 2024 GMT
```

## Applied fix
```bash
sudo postmap -F hash:/etc/postfix/vmail_ssl.map
sudo systemctl restart postfix
sudo systemctl restart dovecot
```

## After fix
- Re-checking 587 STARTTLS and 465 SSL returned the renewed valid certificate.
- Gmail SMTP setup completed successfully with TLS on 587.

Example (sanitized):
```text
notAfter=Jul 30 23:59:59 2026 GMT
```

## Root cause summary
The certificate files had been renewed on disk, but Postfix/Dovecot were still serving the previously cached/mapped certificate context until the Postfix SSL map was rebuilt and mail services restarted.
