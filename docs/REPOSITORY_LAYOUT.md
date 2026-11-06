# Ramez Tunnel Plus — Monorepo Architecture & Directory Layout (Phase 0)

## 1. Top-Level Repository Structure

The project is structured as a unified monorepo enabling synchronized versioning across the Flutter client, Laravel control plane, native Go node agent, and Ansible/Docker infrastructure playbooks.

```
/
├── .github/
│   └── workflows/              # GitHub Actions CI/CD pipelines
│       ├── mobile-ci.yml       # Flutter lint, analyze, tests & APK build
│       ├── backend-ci.yml      # Laravel PHPStan, Pest tests & Docker build
│       └── node-agent-ci.yml   # Go build and multi-arch cross-compilation
├── apps/
│   ├── mobile/                 # Flutter mobile client (Android first, iOS later)
│   ├── backend/                # Laravel 11 API & Filament 3 Admin Panel
│   └── node-agent/             # Go-based edge server monitoring & accounting daemon
├── infra/
│   ├── docker/                 # Dockerfiles & Docker Compose definitions
│   │   ├── docker-compose.yml  # Local dev: Nginx, PHP-FPM, MySQL, Redis, Reverb
│   │   ├── Dockerfile.backend  # Production multi-stage Laravel container
│   │   └── Dockerfile.agent    # Go Node Agent minimal scratch container
│   ├── ansible/                # Automated VPS Node Provisioning
│   │   ├── inventory/          # Staging and production server inventories
│   │   ├── roles/
│   │   │   ├── common/         # UFW firewall, fail2ban, sysctl BBR optimizations
│   │   │   ├── sing-box/       # Automated sing-box server install & systemd unit
│   │   │   └── node-agent/     # Deploying the Go agent binary & TLS certs
│   │   └── provision-node.yml  # Master node provisioning playbook
│   └── nginx/                  # Nginx configuration templates & reverse proxy
├── docs/                       # Engineering specifications and living documentation
│   ├── ARCHITECTURE.md         # System architecture and data flow diagrams
│   ├── DATABASE_ERD.md         # Database ERD and full MySQL table schemas
│   ├── API_CONTRACT.md         # REST API v1 specification and schemas
│   ├── REPOSITORY_LAYOUT.md    # This directory and file layout blueprint
│   ├── INFRASTRUCTURE_PLAN.md  # VPS deployment, domains, and edge routing
│   ├── SECURITY_AND_RISKS.md   # Threat model, privacy, and store compliance
│   └── PROGRESS.md             # Living phase tracker and decision records
├── scripts/                    # Developer tooling and automation scripts
│   ├── setup-dev.ps1           # Windows developer environment bootstrapper
│   └── setup-dev.sh            # Linux/macOS developer environment bootstrapper
├── Makefile                    # Unified root tasks (make test, make lint, etc.)
└── README.md                   # Project overview, quickstart, and engineering guidelines
```

---

## 2. Mobile Client Directory Tree (`apps/mobile/`)

```
apps/mobile/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── kotlin/com/ramez/tunnelplus/
│   │   │       ├── MainActivity.kt
│   │   │       ├── RamezApp.kt
│   │   │       └── vpn/
│   │   │           ├── engine/
│   │   │           │   ├── VpnEngine.kt             # Pluggable interface
│   │   │           │   ├── SingBoxEngine.kt         # libbox integration
│   │   │           │   └── EngineFactory.kt         # Protocol to engine selector
│   │   │           ├── service/
│   │   │           │   ├── RamezVpnService.kt       # Native VpnService & TUN owner
│   │   │           │   └── VpnNotificationManager.kt# Persistent notification & actions
│   │   │           ├── bridge/
│   │   │           │   ├── PigeonGenerated.kt       # Generated Pigeon Kotlin interfaces
│   │   │           │   └── VpnPlatformBridge.kt     # Method & EventChannel handlers
│   │   │           └── tile/
│   │   │               └── VpnQuickTileService.kt   # Android Quick Settings Tile
│   │   └── build.gradle.kts
│   ├── build.gradle.kts
│   └── settings.gradle.kts
├── assets/
│   ├── animations/             # Lottie connection animations
│   ├── flags/                  # Vector flags for server locations
│   ├── icons/                  # Custom SVGs (shield, speed, protocols)
│   └── translations/           # EasyLocalization JSON files
│       ├── ar.json             # Arabic (RTL) complete dictionary
│       └── en.json             # English (LTR) complete dictionary
├── pigeons/
│   └── vpn_api.dart            # Pigeon type-safe schema contract
├── lib/
│   ├── core/
│   │   ├── constants/          # API URLs, app timeouts, storage keys
│   │   ├── di/                 # GetIt & Injectable dependency injection
│   │   ├── errors/             # Failure & Exception classes
│   │   ├── network/            # Dio client, AuthInterceptor, ErrorInterceptor
│   │   ├── platform/           # Generated Pigeon Dart bridges & streams
│   │   ├── routing/            # AutoRoute configuration and guards
│   │   ├── storage/            # Drift database, Hive-CE boxes, SecureStorage
│   │   ├── theme/              # ColorSchemes (5 presets), ThemeExtensions, Typography
│   │   └── widgets/            # Design System components (Buttons, GlassCard, etc.)
│   ├── features/
│   │   ├── auth/               # Login, Register, Forgot Password, Reset
│   │   ├── dashboard/          # Home screen, Animated Connect Button, Live Speed Graph
│   │   ├── servers/            # Server list, Latency ping test, Favorites, Filter
│   │   ├── configurations/     # .rtp parser, Config editor, QR scanner, Import
│   │   ├── connection_details/ # Session statistics, IP lookup, Route viewer
│   │   ├── statistics/         # Usage charts, Session history, CSV export
│   │   ├── subscriptions/      # Plans catalog, Google Play Billing flow
│   │   ├── notifications/      # FCM handler, Notification inbox
│   │   ├── profile/            # User details, Device manager, GDPR erasure
│   │   ├── settings/           # Theme picker, Language toggle, Custom DNS, Split Tunneling
│   │   └── support/            # FAQ, Diagnostic log redactor, Ticket submission
│   ├── main_dev.dart           # Flavor: Development environment
│   ├── main_stage.dart         # Flavor: Staging environment
│   └── main_prod.dart          # Flavor: Production environment
├── test/                       # Unit, BLoC, and parser test suites
└── pubspec.yaml                # Pinned dependencies and asset declarations
```

---

## 3. Laravel Control Plane Directory Tree (`apps/backend/`)

```
apps/backend/
├── app/
│   ├── Console/Commands/       # Scheduled health checks, quota flushes, key rotations
│   ├── Exceptions/Handler.php  # Unified JSON error envelope formatting
│   ├── Http/
│   │   ├── Middleware/         # Sanctum, RoleCheck, RateLimiting, EnforceHttps
│   │   └── Resources/          # Fractal / API Resources for clean JSON output
│   ├── Models/                 # Eloquent Models (User, Server, Plan, etc.)
│   ├── Modules/                # Domain-Driven Subsystems
│   │   ├── Auth/
│   │   ├── Servers/
│   │   ├── Configurations/
│   │   ├── Connections/
│   │   ├── Subscriptions/
│   │   ├── NodeAgent/
│   │   └── Telemetry/
│   ├── Filament/               # Admin Panel Resources, Pages, Widgets & Clusters
│   │   ├── Resources/
│   │   │   ├── UserResource.php
│   │   │   ├── ServerResource.php
│   │   │   ├── PlanResource.php
│   │   │   └── ConfigurationResource.php
│   │   └── Widgets/
│   │       ├── ActiveConnectionsChart.php
│   │       └── RevenueOverviewWidget.php
│   └── Services/               # Business Logic (GooglePlayService, RTPProfileSigner, GeoIP)
├── config/                     # Laravel configuration files
├── database/
│   ├── migrations/             # Full schema migrations
│   └── seeders/                # Default plans, admin roles, and seed servers
├── routes/
│   ├── api.php                 # Versioned /api/v1 routes
│   └── console.php             # Scheduled task definitions
├── tests/
│   └── Feature/                # Pest feature tests for all endpoints
└── composer.json
```

---

## 4. Edge Node Agent Directory Tree (`apps/node-agent/`)

```
apps/node-agent/
├── cmd/
│   └── agent/
│       └── main.go             # Agent daemon entrypoint
├── internal/
│   ├── config/                 # Environment variables and config parser
│   ├── core/                   # sing-box management client (TCP/UNIX socket)
│   ├── metrics/                # System CPU, RAM, and network interface stats
│   ├── accounting/             # User byte tracking, quota aggregation & HMAC signing
│   └── reporter/               # HTTP client reporting to Laravel API
├── go.mod
└── go.sum
```
