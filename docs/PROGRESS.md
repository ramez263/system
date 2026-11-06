# Ramez Tunnel Plus — Project Progress & Living Roadmap

**Project Name:** Ramez Tunnel Plus  
**Platform:** Flutter (Android First, iOS Post-MVP) + Laravel Control Plane + Native sing-box / WireGuard / OpenVPN / SSH  
**Lead Architecture Team:** Senior Flutter, Senior Laravel, Android VPN/Networking, UI/UX, Architecture, Cybersecurity, DevOps  
**Last Updated:** November 6, 2026

---

## 1. Phase Status Overview

| Phase | Description | Status | Exit Gate Condition | Approved By / Date |
|---|---|---|---|---|
| **Phase 0** | **Architecture, ERD, API Contract, Risk Analysis, Monorepo Layout** | **Approved** | Formal Architecture Approval | *Approved by User (2026-11-06)* |
| **Phase 1** | **Foundations (Monorepo, Flutter Skeleton with Flavors, DI, Storage, Network, Laravel Device API, CI)** | **Approved** | App and API build and pass CI | *Approved by User (2026-11-06)* |
| **Phase 2** | **Design System, Multi-Theme, AR/EN RTL, Reusable Widgets, All Mock Screens** | **Approved** | All screens render in both languages & themes | *Approved by User (2026-11-06)* |
| **Phase 3** | **Backend Core (Migrations, Models, Devices, Servers, Configs, Admin MVP, OpenAPI, Tests)** | **Implemented (Pending Sign-off)** | API tests green, OpenAPI published | *Verified Green (23/23 tests, 63 assertions)* |
| **Phase 4** | App Integration (Device Handshake, Servers, Configs, .rtp Engine, Offline Cache) | Ready | Real data flows end-to-end | - |
| **Phase 5** | Native VPN Engine MVP (VpnEngine, sing-box & OpenVPN core, Pigeon Bridge, Reconnect, Quick Tile) | Not Done | Real tunnel connection verified to test node | - |
| **Phase 6** | Curated Servers & Config Pools (OpenVPN servers catalog, community sources, auto-refresh) | Not Done | OpenVPN server pool live and verified in app | - |
| **Phase 7** | Subscriptions & Billing (Google Play Billing, Server-side verification, RTDN) | Not Done | Sandbox purchase unlocks premium | - |
| **Phase 8** | Notifications & Advanced Settings (FCM, Local Alerts, Split Tunneling, Kill-switch) | Not Done | Verified on real physical Android device | - |
| **Phase 9** | Complete Filament Admin Panel (Analytics, Audit Logs, Force Update, Feature Flags) | Not Done | Admin manages full service without DB console | - |
| **Phase 10** | Extra Native Engines (WireGuard, SSH Tun2socks) | Not Done | Each protocol tested against real server | - |
| **Phase 11** | Hardening, Performance, Obfuscation, Google Play Store Preparation | Not Done | Release candidate on internal track | - |
| **Phase 12** | iOS Client (NetworkExtension, Apple VPN Entitlements) | Planned (Post-MVP) | Separate Apple approval & testflight | - |

---

## 2. Key Technical Decisions (ADR Summary)

1. **ADR-001: Separation of Control Plane and Data Plane**
   - *Decision:* Laravel + Filament strictly handles control plane (device telemetry, server catalog, configurations, remote config). User tunnel traffic NEVER traverses Laravel.

2. **ADR-002: Native VPN Core Selection**
   - *Decision:* Native VPN engine supports sing-box (`libbox`) and OpenVPN core (`ics-openvpn` / native TUN) for high compatibility with standard `.ovpn` profiles and modern proxy protocols.

3. **ADR-003: Platform Bridge Architecture**
   - *Decision:* Use `pigeon` for type-safe, bidirectional synchronous/asynchronous calls (`prepare`, `connect`, `disconnect`, `getStatus`) and dual `EventChannel` instances for live status changes and high-frequency traffic byte counters.

4. **ADR-004: Proprietary Open Profile Format (`.rtp`) & OpenVPN Import**
   - *Decision:* Support standard OpenVPN (`.ovpn`) profiles alongside `.rtp` schema. Users can import profiles directly or choose from curated public OpenVPN servers.

5. **ADR-005: State Management & Functional Error Handling**
   - *Decision:* Flutter utilizes `flutter_bloc` with `freezed` immutable state models and `fpdart` `Either<Failure, T>` functional returns.

6. **ADR-006: Device-as-User Identity (Zero Auth Friction)**
   - *Decision:* No user registration or login required. The hardware/app generated `device_uuid` acts as the persistent user identifier for server requests, settings, and quotas.

7. **ADR-007: Curated Public / OpenVPN Server Catalog**
   - *Decision:* Instead of provisioning custom VPS nodes with Ansible/Node Agent, the system utilizes ready-made OpenVPN servers (VPN Gate / curated community pools) alongside user-imported configurations.

---

## 3. Current Phase Work Details: Phase 0

- [x] Comprehensive Architecture Blueprint (`docs/ARCHITECTURE.md`)
- [x] Complete Database Schema & Mermaid ERD (`docs/DATABASE_ERD.md`)
- [x] REST API v1 Specification & OpenAPI Contract (`docs/API_CONTRACT.md`)
- [x] Monorepo Structure & Directory Tree (`docs/REPOSITORY_LAYOUT.md`)
- [x] Infrastructure & Edge Node Deployment Plan (`docs/INFRASTRUCTURE_PLAN.md`)
- [x] Threat Model, Compliance & Security Analysis (`docs/SECURITY_AND_RISKS.md`)
- [ ] User Review and Sign-off on Phase 0 Architecture

---

## 4. Open Questions for User Approval

1. **Server Node Operating System & Hosting:** Do you prefer Ubuntu 24.04 LTS x86_64 for VPS edge nodes (Hetzner, DigitalOcean, OVH, Vultr), or do you have specific cloud providers / ARM64 architectures in mind?
2. **Push Notifications & Analytics:** Shall we default to Firebase Cloud Messaging (FCM) + Firebase Crashlytics for the mobile client, or do you require a self-hosted / privacy-first stack (e.g., Sentry on-premise + UnifiedPush)?
3. **Google Play In-App Billing vs. Multi-Gateway:** For MVP Phase 7, will Google Play Billing be the sole payment rail on Android, or should we scaffold web checkout (Stripe / Cryptomus / local vouchers) alongside it in Laravel?
