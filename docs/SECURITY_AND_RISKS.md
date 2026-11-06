# Ramez Tunnel Plus — Security Analysis, Threat Modeling & Risk Mitigation (Phase 0)

## 1. Threat Modeling & Risk Matrix

| Risk ID | Threat / Attack Vector | Severity | Likelihood | Impact | Technical Mitigation |
|---|---|---|---|---|---|
| **R-01** | **DNS / IPv6 Traffic Leaks** | Critical | Medium | High | Android TUN captures `0.0.0.0/0` and `::/0`. System DNS queries are forcefully captured and routed through encrypted DNS inside sing-box core. IPv6 is routed or dropped cleanly if node lacks IPv6. |
| **R-02** | **Malicious Configuration Import (`.rtp` / URI)** | High | High | High | Import parser accepts data only. Strict JSON Schema validation, no execution of scripts or eval. Max file size capped at 64 KB. User preview dialog required before saving. |
| **R-03** | **Client-Side Traffic Quota Tampering** | Critical | High | High | All traffic accounting is calculated on edge VPS nodes by the Node Agent. Client byte counters are display-only and untrusted. |
| **R-04** | **Credential & Token Theft via Memory / Storage** | High | Medium | High | Sanctum tokens and VPN secrets are stored exclusively in `flutter_secure_storage` backed by Android Keystore (hardware-backed AES-256-GCM). Zero plaintext secrets in SharedPreferences. |
| **R-05** | **Reverse Engineering & APK Decompilation** | High | High | Medium | R8 shrinking and obfuscation enabled in release builds. Native Go sing-box core compiled into binary ELF/AAR (`libbox.so`). Flutter `--obfuscate --split-debug-info` enabled. |
| **R-06** | **Man-in-the-Middle (MitM) on Control Plane** | Critical | Low | High | Strict HTTPS with HSTS. Certificate pinning implemented on the mobile client using `dio_certificate_pinning` targeting `api.rameztunnel.com`. |
| **R-07** | **Google Play Console VPN Policy Rejection** | Critical | Medium | Critical | Strictly adhere to Google Play VPN Service Policy: VPN is the core functionality, no traffic redirection for advertising/resale, clear user consent, comprehensive Data Safety disclosures. |
| **R-08** | **Edge Node Compromise & Key Disclosure** | Critical | Low | Critical | Nodes do not store master database credentials or user passwords. Nodes only receive short-lived user UUIDs. Per-node authentication keys are rotatable via Laravel admin panel. |
| **R-09** | **User Data Logging & Privacy Violations** | High | Low | High | Edge servers pipe proxy access logs directly to `/dev/null`. Laravel records only aggregated byte totals and active session timestamps for quota billing. Zero destination IP or URL history is ever stored. |

---

## 2. Google Play VPN Compliance & Policy Declarations

To ensure seamless Google Play Store approval, the app incorporates the following compliance measures:

1. **Target Android API Level:** Built targeting latest Android SDK (API 34/35) with minimum SDK set to API 26 (Android 8.0 Oreo).
2. **Foreground Service Declarations:**
   - Manifest declares `android:foregroundServiceType="specialUse|connectedDevice"` or `"dataSync"` with the official VPN exception.
   - Persistent notification displays: Connection status, active server name, session duration, and an instant "Disconnect" action button.
3. **User Disclosures & Consent:**
   - Onboarding flow explicitly explains what the VPN does, that traffic will be encrypted and routed through an external server, and requests `VpnService.prepare()` only when the user taps "Connect".
   - Separate rationale dialog before requesting `POST_NOTIFICATIONS` permission (Android 13+).
4. **Data Safety Form Declarations:**
   - Category: Personal Info (Email for account login, optional).
   - Category: Device or other identifiers (Device ID for limiting concurrent sessions).
   - Category: App activity (Data transfer amounts for plan quota calculation).
   - **Declared: NO browsing history, NO web traffic contents, NO IP history sold or shared with advertisers.**

---

## 3. Client-Side Data Redaction Filter

All logging and crash diagnostics pass through a redaction pipeline before writing to disk or dispatching to Sentry/Crashlytics:

```
Unredacted Log Entry:
"Connecting to vless://7a30c51b-e5fb-4c7b-bc43-2fd3f8a0028e@198.51.100.42:443?sni=speed.cloudflare.com, token=1|abcdef123456"

Redacted Output:
"Connecting to vless://[REDACTED_UUID]@[REDACTED_IP]:443?sni=[REDACTED_SNI], token=[REDACTED_TOKEN]"
```

### Redaction Rules (Regex Engine):
- **Bearer Tokens / Sanctum:** `\b\d+\|[A-Za-z0-9+/=]{40,}\b` -> `[REDACTED_TOKEN]`
- **UUIDs / User Keys:** `\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b` -> `[REDACTED_UUID]`
- **Passwords & Secrets:** `(?i)(password|secret|key|token)["']?\s*[:=]\s*["']?([^"',\s]+)` -> `$1: [REDACTED_SECRET]`
- **IPv4 Addresses:** `\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b` -> `[REDACTED_IP]`

---

## 4. GDPR & Data Privacy Guarantees

1. **Right to Erasure (Account Deletion):**
   - The user can trigger complete account deletion directly from the Profile screen (`DELETE /api/v1/auth/account`).
   - Cascade deletes user records, devices, sessions, and encrypted credentials. A 14-day grace period is enforced before permanent database purge, during which tokens remain inactive.
2. **Right to Data Portability:**
   - Users can export their saved configuration profiles in standard `.rtp` format (unless an admin locked the config for security).
   - Usage statistics can be exported to CSV.
