# Ramez Tunnel Plus — Production Monorepo

[![Flutter Mobile CI](https://github.com/rameztunnel/tunnel_plus/actions/workflows/mobile-ci.yml/badge.svg)](https://github.com/rameztunnel/tunnel_plus/actions)
[![Laravel Control Plane CI](https://github.com/rameztunnel/tunnel_plus/actions/workflows/backend-ci.yml/badge.svg)](https://github.com/rameztunnel/tunnel_plus/actions)

Ramez Tunnel Plus is a network tunneling application featuring a Flutter mobile client (Android first, iOS later), a Laravel 11 control plane, and a native VPN engine supporting OpenVPN, sing-box (`libbox`), and modern network protocols.

## Monorepo Layout

* `apps/mobile/`: Flutter client application (Clean Architecture, BLoC, Freezed, Drift, Hive-CE, Pigeon).
* `apps/backend/`: Laravel 11 control plane (Device-based identity, Curated OpenVPN server catalog, Remote config, Filament admin).
* `infra/`: Docker Compose, Nginx configurations, and deployment tooling.
* `docs/`: Engineering architecture blueprints, API contracts, ERD, and progress tracking.

## Quickstart

### Mobile Client (Flutter)
```bash
cd apps/mobile
flutter pub get
flutter run -t lib/main_dev.dart --flavor dev
```

### Control Plane (Laravel)
```bash
cd apps/backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### Docker Compose
```bash
docker compose -f infra/docker/docker-compose.yml up -d
```
