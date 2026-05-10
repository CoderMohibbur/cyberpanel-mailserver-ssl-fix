# Contributing

Thanks for contributing to CyberPanel MailServer SSL Fix.

## What contributions are welcome
- Better and safer certificate checks
- Additional diagnostics that remain non-destructive
- Distro-specific operational notes
- Documentation clarity and troubleshooting improvements

## Changes we do not accept
To keep this repository safe for production use, we reject risky automation such as:
- Automatic Postfix or Dovecot config edits
- Blind certificate deletion
- Package updates/upgrades
- Reboots
- DNS changes

## Contribution guidelines
- Keep examples sanitized (`mail.example.com`, no real account data)
- Do not commit secrets, private keys, or private infrastructure details
- Prefer explicit, readable shell logic over clever but risky shortcuts
- Preserve default check-only behavior in scripts

## Pull request checklist
- [ ] No secrets or sensitive data included
- [ ] Script behavior remains conservative and documented
- [ ] README/docs updated when behavior changes
- [ ] `bash -n scripts/cyberpanel-mail-ssl-fix.sh` passes
