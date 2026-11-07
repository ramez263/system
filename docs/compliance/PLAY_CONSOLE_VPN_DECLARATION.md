# Google Play Console — VPN Service Declaration Form
**Application Name:** Ramez Tunnel Plus  
**Package ID:** `com.ramez.tunnel_plus`  
**Target API:** Android 14+ (API Level 34+)  
**Policy Version:** Google Play Developer Policy — VPN Service Policy (2024–2026)

---

## 1. Core Purpose of the VPN Service

### Question: Why does your application declare and use the `android.net.VpnService`?
**Answer:**
Ramez Tunnel Plus is a specialized, secure network tunneling and VPN application designed to encrypt and route device network traffic through secure proxies and encrypted edge gateways. The `android.net.VpnService` is the **core, indispensable functionality** of the application. Without `VpnService`, the app cannot establish its encrypted TUN virtual network interface, protect user data on insecure public Wi-Fi networks, or mitigate traffic surveillance.

---

## 2. Permitted Use Case Category

### Question: Which category best describes your application's use of `VpnService`?
**Answer:**
- [x] **VPN Service (Core Functionality):** An application whose primary, advertised function is providing a virtual private network service to encrypt and route traffic.

---

## 3. Compliance Affirmations

| Policy Requirement | Compliant? | Architectural Evidence / Implementation |
|---|---|---|
| **No Sale or Brokerage of User Data** | **YES** | All tunnel traffic bypasses intermediate third-party brokers. User browsing history, traffic destinations, and payload packets are never stored or monetized. |
| **No Advertising or Monetization Manipulation** | **YES** | The VPN is strictly a transport tunnel. It does not inject advertisements, redirect user search queries, or manipulate affiliate tracking headers. |
| **User-Initiated Connection Only** | **YES** | The tunnel requires explicit user consent via the standard Android VPN permission dialog (`prepare()`) and an intentional tap of the Connect button or explicit user activation of Auto-Connect rules. |
| **Prominent In-App Disclosure & Privacy Policy** | **YES** | Displayed in onboarding, settings, and before first connection. Clearly discloses that network traffic will be encrypted and routed through the selected server node. |
| **Persistent Notification & Disconnect Control** | **YES** | Implemented in `RamezVpnService.kt` via ongoing foreground notification featuring live session duration, data transferred, and a one-tap "Disconnect" button. |
| **Zero-Logs Architecture** | **YES** | Strict no-logs policy implemented across Flutter and native Android cores; diagnostic logs pass through `DiagnosticLogRedactor` to scrub credentials, keys, and user IPs. |

---

## 4. Foreground Service Declaration & Subtype

- **Permission:** `android.permission.FOREGROUND_SERVICE_SPECIAL_USE`
- **Subtype Property:**
  ```xml
  <property
      android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
      android:value="VPN Tunneling engine routing encrypted traffic and managing kill switch" />
  ```
- **Rationale for Google Play Reviewers:**
  The VPN foreground service maintains a persistent encrypted IP packet tunnel over TUN interface while the screen is off or other apps are running. Android requires a persistent foreground service with ongoing notification to prevent unexpected connection termination and notify users that their network connection is secured.

---

## 5. Review Video Script & Demonstration Steps

For Google Play Console submission, attach a screen recording (maximum 120 seconds) demonstrating:
1. **Launch App:** App opens to the Home Dashboard showing "Disconnected" shield.
2. **Server/Config Selection:** User selects an edge node (e.g. Frankfurt WireGuard or London OpenVPN).
3. **Connection Initiation:** User taps "Connect". Standard Android OS VPN dialog appears requesting permission.
4. **Connected State:** Android key icon appears in status bar. Home screen transitions to "Protected", live upload/download speed gauges activate, and ongoing notification displays live session stats with "Disconnect" button.
5. **Traffic Verification:** Open browser to verify IP address reflects the selected gateway node.
6. **Disconnection:** Tap "Disconnect" in app or notification; VPN interface closes and notification dismisses immediately.
