# GitHub Publishing Guide

## Recommended repository name
`cyberpanel-mailserver-ssl-fix`

## Recommended description
Fix CyberPanel MailServer SSL issues where Gmail/Outlook reject SMTP TLS/SSL because Postfix/Dovecot keep serving an old or expired certificate.

## Recommended topics
- cyberpanel
- mailserver-ssl
- smtp
- smtp-tls
- postfix
- dovecot
- letsencrypt
- gmail-smtp
- ssl-certificate
- mail-server
- email-server
- linux-server

## After pushing to GitHub
1. Confirm raw script URL works:
```bash
curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/scripts/cyberpanel-mail-ssl-fix.sh | head
```

2. Confirm installer URL works:
```bash
curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/master/install.sh | head
```

3. Recommended GitHub repository description:

Fix CyberPanel MailServer SSL issues where Gmail/Outlook reject SMTP TLS/SSL because Postfix/Dovecot keep serving an old or expired certificate.

4. Recommended topics:
- cyberpanel
- mailserver-ssl
- smtp
- smtp-tls
- postfix
- dovecot
- letsencrypt
- gmail-smtp
- ssl-certificate
- mail-server
- email-server
- linux-server

5. Recommended About website field:
Leave blank unless a dedicated documentation page exists.

6. Recommended social preview:
Upload a 1280x640 image in GitHub repository settings -> Social preview.

## Release pinning note
For production use, you can pin commands to a release tag after publishing a release, for example:

```bash
curl -fsSL https://raw.githubusercontent.com/CoderMohibbur/cyberpanel-mailserver-ssl-fix/v1.0.0/scripts/cyberpanel-mail-ssl-fix.sh | sudo bash -s -- --host mail.example.com
```

Do not use the `v1.0.0` command as the main command unless the tag already exists.

## Branch note
If your repository uses a different default branch, replace `master` with your branch name.

## Suggested git commands
```bash
git status
git add .
git commit -m "Add one-line usage and optional installer"
git push
```

For first upstream setup on this repository branch:
```bash
git push -u origin master
```
