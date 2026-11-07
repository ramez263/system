# Privacy Policy for Ramez Tunnel Plus
**Effective Date:** November 7, 2026  
**Last Updated:** November 7, 2026  
**Publisher:** Ramez Tunnel Plus Team  
**Contact:** privacy@rameztunnel.com

---

## 1. Introduction & Zero-Logs Commitment

Welcome to **Ramez Tunnel Plus**. We are committed to protecting your privacy and security. Our application operates under a strict **Zero-Logs Architecture**.

**We do not log, track, monitor, or store:**
- Your browsing activity, websites visited, or search history.
- The contents of any network traffic, packet payloads, or DNS queries routed through our VPN tunnels.
- Your originating real IP address once a session terminates.

---

## 2. Information We Process

Because Ramez Tunnel Plus is built with a **Zero-Login Architecture**, we do not require you to create an account, register an email address, or provide personal identity information.

### A. Device Hardware Identifier (`device_uuid`)
- **What:** A cryptographically random unique identifier generated and stored exclusively within your device's Android Keystore.
- **Why:** To recognize your active device session, authenticate requests to the control plane, manage subscription entitlements, and enforce device limits.
- **Retention:** Retained until you uninstall the application, click "Erase Data & Reset Identity" in Settings, or after 180 days of inactivity.

### B. Subscription & In-App Purchase Records
- **What:** Order ID, purchase token, and expiration timestamp provided by Google Play Billing.
- **Why:** To validate and activate Premium subscription tiers.
- **Retention:** Retained for the statutory duration required by tax and financial compliance regulations.

### C. Redacted Diagnostics & Telemetry
- **What:** Aggregate bandwidth counters (MB transferred) and optional diagnostic crash logs.
- **Why:** To calculate real-time connection speed and maintain server node health.
- **Protection:** All diagnostic dumps pass through an automated `DiagnosticLogRedactor` that strips personal IP addresses, private/public keys, passwords, and tokens before transmission.

---

## 3. How We Secure Your Data

1. **State-of-the-Art Encryption:** All tunnel traffic uses industry-standard protocols (WireGuard ChaCha20-Poly1305, OpenVPN AES-256-GCM, SSH with ed25519 authentication, SingBox TLS Reality).
2. **Control Plane Security:** All API communication is enforced via TLS 1.3 with Certificate Pinning (`network_security_config.xml`).
3. **Android Keystore Security:** Hardware tokens and cryptographic session secrets are protected by Android Hardware Security Modules (HSM) / Secure Enclave via `flutter_secure_storage`.
4. **Anti-Leak Protections:** Built-in IPv6 leak protection, encrypted DNS resolvers (Cloudflare `1.1.1.1` & Google `8.8.8.8`), and native OS kill-switch integration.

---

## 4. Third-Party Services

- **Google Play In-App Billing:** Processes digital subscription payments under Google's Privacy Policy.
- **Firebase Cloud Messaging (FCM):** Delivers critical service maintenance and security announcements without accessing personal message contents.

---

## 5. Your Rights (GDPR & CCPA Compliance)

Regardless of your geographic location, you have the right to:
1. **Access & Portability:** View all data linked to your device identifier directly within the app (Settings > Devices > Telemetry).
2. **Right to Erasure (Forget Me):** Instantly erase your device identifier, subscription link, and telemetry from our backend by tapping "Reset Identity & Delete Data" in Settings > Privacy, or by emailing privacy@rameztunnel.com.

---

## 6. Children's Privacy

Ramez Tunnel Plus does not knowingly collect or solicit any personal information from children under the age of 13 (or under 16 in the European Union).

---

## 7. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. Any material changes will be notified prominently via the in-app announcement banner before taking effect.
