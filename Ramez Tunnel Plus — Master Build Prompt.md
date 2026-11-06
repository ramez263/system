# Ramez Tunnel Plus — Master Build Prompt

Nov 6, 2026 · @Omar Ghazal

Copy everything below this heading into your AI coding tool as the master prompt.

## 1. Role, Mission & Scope

**Project:** Ramez Tunnel Plus — a premium VPN & network-tunneling app. Flutter (Android first) + Laravel control plane + native tunneling engine.

**Act as one product team:** Senior Flutter Engineer, Senior Laravel Engineer, Android VPN/Networking Engineer, UI/UX Designer, Software Architect, Cybersecurity Engineer, DevOps Engineer.

**Mission:** Design and build a real, modular, production-ready tunneling application. Beginners must connect with one tap; professionals get an Advanced section with full control. It is a working product, not a prototype and not a static UI.

**Identity:** The app is called **Ramez Tunnel Plus**. It is inspired by the category of tunnel-style apps but must have its own visual identity, its own configuration format and its own code. Do not copy any other app's name, logo, assets, layouts, strings or file format.

**Legal and ethical boundary:** The app supports only authorized network access: servers the operator owns or is permitted to use. Do not build features whose purpose is to evade a carrier's billing or terms of service, and do not implement anything that deceives users or Google Play reviewers.

### Scope

- **Platform:** Android first. iOS is a later phase and starts only after Android is stable (it needs NetworkExtension and Apple's VPN entitlement).
- **MVP:** authentication, server list from the API, configuration import, connect/disconnect through the sing-box core, live statistics, settings (theme and language), FCM notifications, basic Filament admin (users, servers, plans).
- **Post-MVP:** WireGuard, OpenVPN and SSH engines, subscriptions and Play Billing, map view, split tunneling UI, referral system, advanced analytics, iOS.
- **Honesty rule:** Every protocol or feature is labeled *working*, *partial* or *planned* in each phase report. A visual placeholder is never reported as a finished feature.

## 2. Tech Stack & Tooling (fixed decisions, do not substitute)

**Mobile (Flutter, latest stable, Dart)**

- State: BLoC/Cubit with `freezed` states and `fpdart` (`Either`) for error handling.
- DI: `get_it` + `injectable`. Navigation: `auto_route`. Network: `dio` with interceptors (auth, retry, logging with redaction).
- Storage: `drift` for relational data (configs, history, stats); `hive_ce` for light cache; `flutter_secure_storage` for tokens, keys and credentials. The original `hive` package is unmaintained: do not use it.
- UI: `flutter_animate`, `loading_animation_widget`, `fl_chart` for graphs, `easy_localization` for i18n.
- Platform bridge: `pigeon` for typed calls plus `EventChannel` for status and stats streams.
- Push: `firebase_messaging` + `flutter_local_notifications`. Billing: `in_app_purchase`. Crash reporting: Sentry or Firebase Crashlytics with log redaction.
- Flavors: `dev`, `stage`, `prod`.

**Backend (Laravel, latest stable, PHP 8.3+)**

- MySQL, Redis (cache, queues), Laravel Sanctum, Laravel Horizon for queues, Laravel Reverb for real-time, Scheduler for periodic jobs.
- Admin panel: **Filament** with Spatie `laravel-permission` for roles.
- API docs: Scribe or L5-Swagger (OpenAPI). Tests: Pest.
- All APIs versioned under `/api/v1`. All responses through API Resources. All input through Form Requests.

**Native Android:** Kotlin, `VpnService`, foreground service, Gradle with R8 shrinking and obfuscation.

**Infrastructure:** Docker and Docker Compose for Laravel and for server nodes, GitHub Actions for CI/CD, Nginx, Let's Encrypt, Ansible for node provisioning.

## 3. Native VPN Engine (decision, do not substitute)

Flutter cannot tunnel traffic by itself. The tunnel runs natively. Laravel never carries user traffic: it is the control plane only (users, servers, credentials, plans, monitoring).

| Protocol family | Engine | Phase |
| --- | --- | --- |
| VLESS, VMess, Trojan, Shadowsocks, Hysteria2, TUIC, SOCKS, HTTP, WebSocket, gRPC, TLS/Reality transports | sing-box core (`libbox`) | MVP |
| WireGuard | Official WireGuard Android tunnel library (`wireguard-android`) | Post-MVP |
| OpenVPN | `ics-openvpn` (or its maintained fork) | Post-MVP |
| SSH tunnel (password and key auth, optional SNI/TLS and WebSocket wrapper) | `sshj` in Kotlin, local SOCKS5 plus `tun2socks` into the TUN | Post-MVP |
| DNS tunneling (DNSTT) | Only if the operator owns the DNS zone and server; separate optional phase | Optional |

**Architecture rules**

1. Define a Kotlin `VpnEngine` interface: `connect(profile)`, `disconnect()`, `status: Flow<ConnectionStatus>`, `stats: Flow<TrafficStats>`, `supports(protocol)`. Every engine is a pluggable implementation selected by a factory.
2. One `VpnService` subclass owns the TUN interface and runs as a foreground service with the correct `foregroundServiceType` for the target SDK, a persistent notification with a Disconnect action, and `POST_NOTIFICATIONS` handled at an appropriate moment.
3. The Dart side talks to it only through Pigeon APIs (`prepare`, `connect`, `disconnect`, `getStatus`, `listEngines`) plus EventChannels for status and traffic streams. No protocol logic in Dart.
4. Status states: `disconnected`, `preparing`, `connecting`, `connected`, `reconnecting`, `failed(reason)`. Reconnect uses exponential backoff and reacts to network changes through `ConnectivityManager.NetworkCallback`.
5. Handle VPN permission denial, revoked VPN, process death and service restart explicitly.
6. Support DNS settings, IPv6 handling, DNS leak protection, kill switch (via always-on and lockdown guidance), per-app split tunneling (`addAllowedApplication` / `addDisallowedApplication`) and a Quick Settings Tile.
7. Pin exact library versions, document how each native artifact is built or fetched, and verify its license before bundling.
8. Any protocol that is not wired to a real engine must not appear in the UI. No fake options.

## 4. Configuration System & File Format

**Do not reverse-engineer, decrypt or clone any third-party proprietary config format** (including `.hat` files). Create our own open, versioned format instead.

**Native format: `.rtp` (Ramez Tunnel Profile)**

- JSON with `schemaVersion`, validated against a JSON Schema on import and export.
- Fields: name, protocol, server, port, auth method, transport (TCP/WebSocket/gRPC/TLS), SNI, host header, custom headers, TLS options (ALPN, fingerprint, certificate pinning), DNS, proxy chain, timeout, keep-alive, notes.
- Optional payload encryption (AES-256-GCM with a key derived from a user passphrase via Argon2id) and an optional Ed25519 signature so official configs from the admin panel can be verified as authentic.
- A locked config can hide its secrets from the user while still being usable (the secret lives encrypted in the app and is never shown or exported).

**Import support**

- `.rtp` files, `vmess://`, `vless://`, `trojan://`, `ss://`, `hy2://` URIs and subscription links (base64 lists).
- OpenVPN `.ovpn` and WireGuard `.conf` files.
- Manual entry for SSH, SOCKS5 and HTTP CONNECT.
- Import through the Android file picker, share intent, QR scan and clipboard.

**Safe parsing rules**

- Imported content is data only. Never execute it, never `eval`, never follow embedded commands or URLs automatically.
- Enforce size limits, strict schema validation and an allow-list of fields. Reject unknown dangerous options with a clear message.
- Show a preview and require user confirmation before saving.

**Management features:** create, edit, duplicate, rename, delete, folders, default config, connectivity test (real handshake test with latency result), details view, export where the config is not locked, and sharing via the Android share sheet.

**Editor fields:** name, server address and port, username and password or key (stored in secure storage), auth method, proxy settings, payload/host settings, SNI, TLS settings, DNS, custom headers, connection timeout, keep-alive, advanced options. Validate each field live.

## 5. Design System, UX, Theming & Localization

**Design principles:** modern, minimal, premium. Gradients, restrained glassmorphism, soft shadows, rounded corners, clear typography, consistent spacing, smooth transitions. No clutter. Advanced options live in a separate Advanced section.

**Core UX promise:** open the app, tap one button, connected. Everything else is optional.

**Build a design system first:** design tokens (colors, spacing, radius, elevation, typography), a `ThemeExtension`, and reusable widgets (primary button, glass card, status chip, list tile, empty state, error state, skeleton loader, offline banner). Every screen uses only these.

**Theming**

- Light, Dark, System.
- Presets: Ocean Blue, Purple, Emerald, Midnight, Sunset, plus a custom accent color picker.
- All colors come from `ColorScheme` generated from the chosen seed. The whole app, including graphs and the connect button, adapts instantly.
- Persist locally and sync to the account.
- Contrast must meet WCAG AA in every preset.

**Localization**

- Arabic and English from day one with `easy_localization`; architecture ready for more languages.
- Full RTL: mirrored layouts, directional icons, `EdgeInsetsDirectional`, correct Arabic font (for example Cairo or IBM Plex Sans Arabic), localized dates, numbers and plurals.
- Switch language at runtime without restart.
- Zero hardcoded user-facing strings; CI fails if a key is missing in either language.

**Motion and performance:** animations use `RepaintBoundary`, respect the system reduce-motion setting, and pause when the app is in the background. The connected state visibly transforms the home screen (color shift, pulse ring, shield state) without hurting battery.

**Accessibility:** minimum 48 dp touch targets, semantic labels, text scaling up to 200%, screen-reader support.

## 6. App Features

**Home dashboard**

- Large animated Connect/Disconnect button with states: Disconnected, Connecting, Connected, Reconnecting, Failed.
- Session timer, selected server and config, protocol, public IP (fetched through the tunnel), live download and upload speed, session totals, ping, packet loss when measurable, live graph.
- Quick actions: Quick Connect, Select Server, Select Config, Import Config, History, Advanced Settings.

**Servers**

- Fetched from Laravel with pagination and caching. Fields: name, country and flag, city, ping, load, availability, supported protocols, plan tier.
- Search, filter by country and protocol, sort by ping or load, favorites, recently used, automatic best-server selection based on measured latency plus server load.
- Server details screen. Map-based selection (post-MVP).

**Connection features**

- Auto reconnect with backoff, automatic retry, connection timeout, network-change handling (Wi-Fi to mobile), custom DNS, DNS leak protection, IPv6 handling, kill switch guidance (Always-on VPN and Lockdown), split tunneling with app exclusion, auto-connect on startup, on Wi-Fi, on mobile data, connection logs with redaction, battery-optimization guidance, persistent connection notification.

**Statistics and history**

- Daily, weekly and monthly usage charts with date filters, totals, session durations, most-used servers, connection history, CSV export.
- Per-account usage totals come from the server-side accounting (section 8). Device-side counters are only for the live display.

**Settings:** appearance, language, notification categories (connection, disconnection, server failure, subscription expiry, security alerts, updates, promotions), default server and protocol, data-usage alerts, clear cache, privacy, about, terms, privacy policy, contact support.

**Support center:** FAQ, troubleshooting guide, tickets, report a connection problem, send diagnostic logs (never containing passwords, keys, tokens or full IPs of users), feedback.

**Notifications:** FCM push and local notifications, managed from Laravel. Ask for permission only at a meaningful moment, with an explanation. Never send needless notifications.

**Screens (all must exist, share the design system and handle loading, empty, error and offline states):** Splash, Onboarding, Welcome, Login, Register, Forgot/Reset Password, Home, Server List, Server Details, Config List, Config Editor, Import Config, Connection Details, Statistics, History, Plans, Payment History, Profile, Devices, Appearance, Language, Notifications, Advanced Network Settings, App Settings, Support Center, FAQ, About.

## 7. Accounts, Subscriptions & Billing

**Accounts:** register, login, logout, forgot and reset password, email verification, profile, change password, device management and active sessions, account deletion (full GDPR-style erasure with a documented retention window), optional guest mode for the Free tier. Device limits per plan are enforced by the backend.

**Plans:** Free, Premium, Professional. Plans, limits, entitlements and prices are database-driven and editable in the admin panel. **No prices or limits are hardcoded** in the app; the app reads them from the API.

**Entitlements:** which servers, which protocols, bandwidth or data caps, device count, priority support. The backend decides what each user may use and issues per-user credentials only to entitled users.

**Billing**

- Google Play Billing through `in_app_purchase` for digital subscriptions inside the Android app (Google Play policy requires it).
- Server-side purchase verification with the Google Play Developer API from Laravel, plus Real-time Developer Notifications for renewals, cancellations and refunds.
- A `PaymentProvider` interface in Laravel so other providers (web checkout, crypto, local gateways) can be added without touching the app. Web-only providers are used only where store policy allows.
- Transaction history, expiry and renewal handling, grace period, promo codes, referral rewards, and usage limits with clear in-app messaging when a limit is reached.

## 8. Backend, Admin Panel & Server Infrastructure

**Laravel modules:** Auth, Users, Devices, Servers, Configurations, Connections, Plans, Subscriptions, Payments, Notifications, Analytics, Support, AppRelease (versions, force update, maintenance, remote config, feature flags), Admin. Provide migrations, models with relationships, controllers, services, repositories only where justified, API Resources, Form Requests, Policies, middleware, events, jobs, scheduled tasks and seeders.

**Filament admin panel** with Spatie roles and permissions (Super Admin, Admin, Support, Finance, Read-only)

- Dashboard: total and active users, online connections, servers, subscriptions, revenue, traffic, recent activity.
- Users: search, suspend and activate, subscriptions, device limits, activity.
- Servers: add, edit, enable or disable, locations, supported protocols, health and load, credential rotation.
- Configurations: create, publish, sign, assign to plans, availability.
- Plans, payments, coupons, promotions.
- Notifications: send, target groups, schedule, delivery statistics.
- App management: versions, force update, minimum version, maintenance mode, remote config, feature flags.
- Analytics: user growth, daily active users, server performance, network usage, revenue.
- Audit log for every admin action.

**Server nodes and Node Agent**

- Each VPS node runs the proxy core (sing-box, WireGuard, OpenVPN, SSH as needed) provisioned with Docker Compose and Ansible. Provide the playbooks and templates.
- A small **Node Agent** (Go or PHP CLI) on each node reports health, CPU, bandwidth, active sessions and **per-user traffic** to Laravel over mTLS or signed requests, and applies user add, remove and key-rotation commands from Laravel.
- **Traffic accounting is server-side only.** Data caps and usage statistics never trust the client.
- Laravel issues short-lived or per-user credentials. Server root credentials and shared master secrets are never sent to the app. Provide a key-rotation procedure.
- Multi-provider, multi-region by design: a `servers` table with provider, region and capacity, and a health-check scheduler that automatically marks degraded nodes unavailable.
- Real-time updates (server status, plan changes) through Reverb.

## 9. Security, Privacy & Android Compliance

**API and backend**

- HTTPS only with HSTS, Sanctum tokens with expiry and per-device revocation, rate limiting (stricter on auth and password reset), validation on every input, Eloquent or parameterized queries only, Argon2id or bcrypt password hashing, policies on every resource, CORS locked down, secure file-upload validation, audit logs.
- Sensitive columns (VPN credentials, private keys, API secrets) encrypted at rest with Laravel encryption and a rotatable key. Never log secrets.
- Secrets in environment variables or a secret manager, never in the repository.

**Mobile app**

- Tokens and credentials only in `flutter_secure_storage` (Android Keystore backed). No secrets in `SharedPreferences`, logs or screenshots.
- Certificate pinning for the API, R8 shrinking and obfuscation, `--obfuscate --split-debug-info` for Flutter builds, `FLAG_SECURE` on sensitive screens, root and tamper detection used as an informational signal only.
- Diagnostic logs pass through a redaction filter that removes passwords, keys, tokens and user IPs.

**Privacy**

- Publish a clear no-logs and data-retention policy and make the code match it: do not store browsing activity or traffic content. Keep only what billing, abuse prevention and quotas need, with defined retention periods and automatic purge jobs.
- GDPR-style data export and deletion, minimal analytics, user consent for optional telemetry and promotional notifications.

**Android and Google Play requirements**

- Correct `foregroundServiceType`, `BIND_VPN_SERVICE` permission, `POST_NOTIFICATIONS` flow, Quick Settings Tile, Always-on VPN and Lockdown guidance, battery-optimization guidance, target the current required API level.
- Prepare the Play Console VPN service declaration, Data Safety form and privacy policy. The VPN may be used only for its core function, must not intercept or redirect traffic for ads or resale, and must not misrepresent what it does.
- Every feature that needs native code, external infrastructure, a permission or a third-party account must be listed explicitly in the phase report with setup steps.

## 10. Architecture, Testing & Operations

**Flutter structure:** Clean Architecture with feature modules. Each feature has `presentation` (pages, widgets, bloc), `domain` (entities, use cases, repository contracts) and `data` (models, data sources, repository implementations).

```
lib/
  core/ (constants, theme, l10n, routing, network, storage, errors, widgets, services, di)
  features/
    auth/  dashboard/  vpn_connection/  servers/  configurations/
    statistics/  subscriptions/  notifications/  profile/  settings/  support/
  main_dev.dart  main_stage.dart  main_prod.dart
android/app/src/main/kotlin/.../vpn/ (engine/, service/, bridge/, tile/)
```

Rules: no oversized files, no duplicated code, dependency injection everywhere, proper loading, empty, error and offline states, and no business logic inside widgets.

**Laravel structure:** modular (`app/Modules/*` or domain folders), thin controllers, logic in services and actions, API Resources for every response, OpenAPI documentation generated and kept up to date.

**Quality targets:** fast cold start, minimal battery use, pagination, caching, resilience on unstable networks, correct handling of app lifecycle and process death, no memory leaks, efficient animations, phones and tablets.

**Testing (each phase ships its tests)**

- Flutter: unit tests for use cases, blocs and parsers; widget and golden tests for key screens in LTR and RTL; integration tests for the main flows.
- Android native: unit tests for the config-to-engine mapper and state machine; an instrumented test that connects through a test node.
- Laravel: Pest feature tests for every endpoint, policy tests, billing verification tests with mocked Google responses, security tests for authorization and rate limits.
- Config parser fuzz tests with malformed and hostile input.

**CI/CD and operations:** GitHub Actions running format, analyze, tests and builds (Flutter and Laravel), signed release builds, Docker images, staging and production environments, database backups, Sentry or Crashlytics, uptime and node-health alerts, a deployment guide and a runbook.

## 11. Delivery Phases

Execute exactly one phase per response, then stop and wait for my approval. Phases 0 to 6 produce the Android MVP.

| Phase | Scope | Exit gate |
| --- | --- | --- |
| 0. Architecture | Requirements, final architecture, data model (ERD), API contract draft, infrastructure plan, risk list, repo layout, assumptions | I approve the architecture |
| 1. Foundations | Monorepo setup, Flutter app skeleton with flavors, DI, routing, network and storage layers, Laravel skeleton with auth scaffolding, Docker Compose, CI | App and API build and pass CI |
| 2. Design system and screens | Tokens, themes with all presets, Arabic and English with RTL, reusable widgets, every screen built with mock data, golden tests | All screens render in both languages and themes |
| 3. Backend core | Migrations, models, auth, devices, servers, configs, plans, entitlements, credential issuing, basic Filament resources for users, servers and plans (MVP admin), OpenAPI docs, Pest tests | API tests green, OpenAPI published |
| 4. App integration | Auth flows, server list, config management and import, `.rtp` parser and other importers, offline cache | Real data flows end to end |
| 5. Native engine (MVP) | `VpnEngine` interface, `VpnService`, foreground service, sing-box integration, Pigeon bridge, status and stats streams, reconnect, DNS, Quick Settings Tile | Real connection to a test node with verified traffic |
| 6. Node infrastructure | Node Agent, Docker and Ansible provisioning, health reporting, server-side traffic accounting, key rotation | A fresh VPS is provisioned and appears in the app |
| 7. Subscriptions and billing | Plans, Google Play Billing, server-side verification, RTDN, promo codes, referrals, usage limits | Sandbox purchase unlocks premium |
| 8. Notifications and settings | FCM, local notifications, categories, auto-connect rules, split tunneling, kill-switch guidance, statistics and history | Features verified on a real device |
| 9. Admin panel | Complete Filament panel, roles, analytics, feature flags, force update, maintenance mode | Admin can run the service without a database console |
| 10. Extra engines | WireGuard, OpenVPN, SSH tunnel engines behind `VpnEngine` | Each protocol tested against a real server |
| 11. Hardening and release | Security review, performance and battery profiling, obfuscation, pinning, Play Console declarations, store listing assets, runbook | Release candidate on the Play Console internal track |
| 12. iOS (optional) | NetworkExtension target and App Store requirements | Separate approval |

**Every phase response must contain, in this order**

1. What will be built and why (short).
2. Assumptions, and at most three questions if something blocks progress.
3. The complete files with full paths. No `...`, no placeholders, no pseudo-code.
4. Key technical decisions and trade-offs.
5. Exact commands to run, tests to run, and how to verify on a device.
6. External requirements (accounts, keys, VPS, Play Console, Firebase) with setup steps.
7. A status report: **Done**, **Partially done**, **Not done**, and known issues.

## 12. Working Rules & Start Instruction

**Working rules**

- One phase per response. Stop at the exit gate and wait for my approval.
- Do not invent library names, versions or APIs. If unsure, say so and propose how to verify (read the official docs or build a small spike).
- Never claim something works unless it was built, run and tested. If you cannot run code, say which parts are untested and give me the commands to test them.
- Never report a placeholder or mock as a finished feature. Mark it clearly as mock.
- Prefer small, complete, reviewable files over huge dumps. Keep each file focused.
- When a request conflicts with security, store policy or law, explain why and propose a compliant alternative.
- Keep a living `docs/PROGRESS.md` (done, partial, not done, decisions, open questions) and update it every phase.

**Final priorities, in order**

1. Reliable and secure tunneling engine.
2. One-tap connection experience and excellent UI/UX.
3. Full Arabic and English with RTL.
4. Theme and color customization.
5. Flexible configuration management with our own `.rtp` format.
6. Scalable Laravel backend and server-side accounting.
7. Professional Filament admin panel.
8. Production-ready architecture, tests and CI/CD.

**Start now:** Run **Phase 0**. Present the complete architecture, an ERD of the database, the API surface, the module boundaries between Flutter, Laravel, the native engine and the nodes, the infrastructure needed (VPS, Firebase, Play Console, domains), the main risks with mitigations, and any assumptions. Ask at most three questions, then wait for my approval before Phase 1.
