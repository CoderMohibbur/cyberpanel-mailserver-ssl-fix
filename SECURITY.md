# Security Policy

## Data safety for issues and discussions
This is a public repository. Do not post secrets or customer-sensitive data.

Never share:
- Private keys (`privkey.pem`, key material, or certificates tied to real domains)
- Passwords or access tokens
- Real customer/client email addresses, hostnames, IP addresses, or account identifiers
- Unsanitized logs that include sensitive metadata

## Safe diagnostics
When requesting help, use sanitized output only:
- Replace real domains with `mail.example.com`
- Remove user identities and mailbox names
- Redact any IDs or values that can identify a specific environment

## Reporting potential vulnerabilities
Open an issue with a high-level description first, without sensitive details. If additional context is needed, sanitize all artifacts before sharing.
