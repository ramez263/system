# Google Play Console — Data Safety Form Specification
**Application:** Ramez Tunnel Plus (`com.ramez.tunnel_plus`)  
**Version:** 1.0.0 (Build 1)  
**Standard:** Google Play Data Safety Requirements

---

## 1. Overview Summary

- **Does your app collect or share any user data?**  
  **Yes** (Limited to device hardware identifier for quota tracking, in-app billing tokens, and anonymous crash telemetry).
- **Is all data collected encrypted in transit?**  
  **Yes** (All API communication uses TLS 1.3 / HTTPS with Certificate Pinning; tunnel traffic is encrypted with ChaCha20-Poly1305 or AES-256-GCM).
- **Does your app provide a way for users to request data deletion?**  
  **Yes** (One-tap "Reset Device Identity / Erase Data" in Settings > Privacy, plus server-side automated retention purging).

---

## 2. Detailed Data Type Disclosures

### A. Device or Other Identifiers
- **Data Collected:** Device ID / Hardware UUID (`device_uuid`).
- **Is it shared with third parties?** No.
- **Is it processed ephemerally?** No (stored securely in Android Keystore).
- **Is it required or optional?** Required (acts as the zero-login user identity).
- **Purposes:**
  1. **App Functionality:** Authentication and multi-device connection limits.
  2. **Fraud Prevention & Security:** Preventing voucher code abuse and DDoS attacks.
  3. **Account Management:** Binding active subscription status to the hardware device without requiring email or passwords.

### B. Financial Information
- **Data Collected:** Purchase History (Google Play Billing Order ID, Purchase Token, Subscription Plan SKU).
- **Is it shared with third parties?** No (verified directly via Google Play Developer API).
- **Purposes:**
  1. **App Functionality:** Unlocking VIP servers and removing bandwidth caps.

### C. App Performance & Diagnostics
- **Data Collected:** Crash logs, diagnostic performance logs.
- **Is it shared?** No.
- **Purposes:**
  1. **Analytics & Diagnostics:** Troubleshooting connectivity issues.
- **Redaction Guarantee:**
  All diagnostic dumps pass through `DiagnosticLogRedactor` which scrubs user IPs, passwords, private keys, and hardware UUIDs before transmission.

---

## 3. Strict Non-Collection Affirmations (What We NEVER Collect)

| Data Category | Collected? | Policy Commitment |
|---|---|---|
| **Browsing History** | **NO** | Zero logging of visited websites, DNS lookups, or browsing destinations. |
| **Traffic Content & Payload** | **NO** | VPN tunnel payload is end-to-end encrypted; server nodes never inspect or log payload data. |
| **Personal Information (Name, Email, Phone)** | **NO** | Zero-login architecture. No email, phone number, or names are requested or stored. |
| **Location (GPS / Coarse)** | **NO** | App does not request `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION`. |
| **Contacts & Media** | **NO** | App does not access device contacts, photos, or storage media outside of explicit configuration imports. |

---

## 4. Data Safety JSON Export (For Automated Play Console Imports)

```json
{
  "dataSafety": {
    "dataCollection": true,
    "encryptedInTransit": true,
    "deletionRequestSupported": true,
    "dataTypes": [
      {
        "category": "Device or other identifiers",
        "type": "Device ID",
        "collected": true,
        "shared": false,
        "ephemeral": false,
        "required": true,
        "purposes": ["App functionality", "Fraud prevention", "Account management"]
      },
      {
        "category": "Financial info",
        "type": "Purchase history",
        "collected": true,
        "shared": false,
        "ephemeral": false,
        "required": false,
        "purposes": ["App functionality"]
      },
      {
        "category": "App info and performance",
        "type": "Crash logs",
        "collected": true,
        "shared": false,
        "ephemeral": true,
        "required": false,
        "purposes": ["Analytics"]
      }
    ]
  }
}
```
