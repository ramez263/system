# Ramez Tunnel Plus — REST API v1 Specification & Contract (Phase 0)

## 1. Global Standards & Envelope Structure

- **Base URL:** `https://api.rameztunnel.com/api/v1`
- **Content-Type & Accept:** `application/json`
- **Authentication:** `Authorization: Bearer <SanctumToken>`
- **Rate Limiting:**
  - Global API: `60 requests / minute`
  - Auth endpoints (`/auth/login`, `/auth/register`): `10 requests / minute`
  - Password reset: `3 requests / minute`
- **Standard Response Envelope:**

```json
{
  "status": "success",
  "message": "Operation completed successfully.",
  "data": {},
  "errors": null,
  "meta": {
    "timestamp": "2026-11-06T18:00:00Z",
    "api_version": "1.0.0"
  }
}
```

- **Standard Error Envelope:**
```json
{
  "status": "error",
  "message": "Validation failed for provided parameters.",
  "data": null,
  "errors": {
    "email": ["The selected email is invalid or already registered."]
  },
  "meta": {
    "timestamp": "2026-11-06T18:00:00Z",
    "error_code": "ERR_VALIDATION_FAILED"
  }
}
```

---

## 2. Authentication & Account Management

### `POST /auth/register`
Creates a new user and registers the initial mobile device.
- **Request Body:**
```json
{
  "name": "Ramez User",
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!",
  "device": {
    "device_uuid": "d4e5f6a7-89bc-4def-9012-3456789abcde",
    "device_name": "Google Pixel 8",
    "model": "Pixel 8",
    "os_version": "Android 14",
    "app_version": "1.0.0",
    "push_token": "fcm_token_example_string"
  }
}
```
- **Response `201 Created`:**
```json
{
  "status": "success",
  "message": "Account registered successfully.",
  "data": {
    "token": "1|sanctum_plain_text_token_string",
    "user": {
      "id": 101,
      "name": "Ramez User",
      "email": "user@example.com",
      "role": "user",
      "plan": {
        "tier": "free",
        "name": "Free Tier",
        "max_devices": 1,
        "speed_limit_mbps": 10
      }
    }
  }
}
```

### `POST /auth/login`
Authenticates a user and binds the device.
- **Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "device": {
    "device_uuid": "d4e5f6a7-89bc-4def-9012-3456789abcde",
    "device_name": "Google Pixel 8",
    "os_version": "Android 14",
    "app_version": "1.0.0",
    "push_token": "fcm_token_example_string"
  }
}
```
- **Response `200 OK`:** Returns user data and Sanctum bearer token.

### `POST /auth/logout`
Revokes the current device token.
- **Headers:** `Authorization: Bearer <token>`
- **Response `200 OK`:** `{"status": "success", "message": "Successfully logged out."}`

### `DELETE /auth/account` (GDPR Data Erasure)
Permanently queues account erasure and revokes all sessions.
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:** `{"password": "SecurePassword123!"}`
- **Response `200 OK`:** `{"status": "success", "message": "Account scheduled for complete erasure."}`

---

## 3. Server Registry & Discovery

### `GET /servers`
Returns a list of accessible server nodes with active status and real-time load.
- **Headers:** `Authorization: Bearer <token>`
- **Query Parameters:**
  - `protocol`: Filter by protocol (`vless`, `trojan`, `hysteria2`, `wireguard`, etc.)
  - `country`: 2-letter ISO code (`DE`, `US`, `SG`)
  - `sort`: `ping` | `load` | `country`
  - `page`: Pagination page number
- **Response `200 OK`:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 12,
      "name": "Frankfurt Premium 01",
      "host": "de-fra-01.nodes.rameztunnel.com",
      "ip_address": "198.51.100.42",
      "port": 443,
      "country_code": "DE",
      "country_name": "Germany",
      "city": "Frankfurt",
      "latitude": 50.1109,
      "longitude": 8.6821,
      "flag_emoji": "🇩🇪",
      "supported_protocols": ["vless", "trojan", "hysteria2"],
      "current_load": 28,
      "ping_ms": 32,
      "is_premium_only": true,
      "is_active": true
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "total": 28
  }
}
```

### `GET /servers/best`
Returns the optimal server node based on client IP proximity, measured latency, and node capacity.
- **Headers:** `Authorization: Bearer <token>`
- **Response `200 OK`:** Returns single server object.

---

## 4. Configurations & Credential Issuance

### `GET /configs`
Returns list of official and user-custom configurations.
- **Headers:** `Authorization: Bearer <token>`
- **Response `200 OK`:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 5,
      "server_id": 12,
      "name": "Frankfurt Reality WebSocket",
      "protocol": "vless",
      "transport": "ws",
      "sni": "speed.cloudflare.com",
      "host_header": "de-fra-01.nodes.rameztunnel.com",
      "is_locked": true,
      "is_official": true,
      "min_plan_tier": 1,
      "ed25519_signature": "abf304...signature"
    }
  ]
}
```

### `POST /configs/{id}/credentials`
Issues a short-lived tunnel credential for connecting to the given configuration/server.
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
```json
{
  "device_uuid": "d4e5f6a7-89bc-4def-9012-3456789abcde"
}
```
- **Response `200 OK`:**
```json
{
  "status": "success",
  "data": {
    "protocol": "vless",
    "uuid": "7a30c51b-e5fb-4c7b-bc43-2fd3f8a0028e",
    "flow": "xtls-rprx-vision",
    "server": "198.51.100.42",
    "port": 443,
    "transport": "tcp",
    "security": "reality",
    "reality_settings": {
      "public_key": "9d90...pubkey",
      "short_id": "8b9a10",
      "server_name": "speed.cloudflare.com"
    },
    "lease_expires_at": "2026-11-06T20:00:00Z"
  }
}
```

---

## 5. Connections & Device Enforcement

### `POST /connections/lease`
Verifies plan entitlement, checks concurrent device limits, and registers an active tunnel session.
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
```json
{
  "server_id": 12,
  "device_uuid": "d4e5f6a7-89bc-4def-9012-3456789abcde",
  "protocol": "vless"
}
```
- **Response `200 OK`:** Returns `session_token` valid for the connection.
- **Error `403 Forbidden` (`ERR_DEVICE_LIMIT_EXCEEDED`):**
```json
{
  "status": "error",
  "message": "Maximum active device limit reached for your plan (1 device). Please disconnect other devices or upgrade to Pro.",
  "errors": null,
  "meta": { "error_code": "ERR_DEVICE_LIMIT_EXCEEDED" }
}
```

### `POST /connections/release`
Notifies the backend that a tunnel session has gracefully disconnected.
- **Request Body:**
```json
{
  "session_token": "sess_89a0b1c2d3e4",
  "bytes_uploaded": 15428900,
  "bytes_downloaded": 104289000,
  "duration_seconds": 1820
}
```

---

## 6. Plans & Google Play Billing

### `GET /plans`
Returns the public plan catalog with limits, device counts, and prices.
- **Response `200 OK`:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "slug": "free",
      "name": "Free Starter",
      "tier_level": 0,
      "max_devices": 1,
      "speed_limit_mbps": 10,
      "monthly_bandwidth_bytes": 10737418240,
      "price_formatted": "Free",
      "google_play_product_id": null
    },
    {
      "id": 2,
      "slug": "premium_monthly",
      "name": "Premium VIP",
      "tier_level": 1,
      "max_devices": 5,
      "speed_limit_mbps": 0,
      "monthly_bandwidth_bytes": 0,
      "price_cents": 499,
      "currency": "USD",
      "price_formatted": "$4.99 / month",
      "google_play_product_id": "com.ramez.tunnelplus.premium.monthly"
    }
  ]
}
```

### `POST /subscriptions/verify-purchase`
Server-side receipt verification against Google Play Developer API.
- **Request Body:**
```json
{
  "product_id": "com.ramez.tunnelplus.premium.monthly",
  "purchase_token": "in_app_purchase_token_from_google_play_sdk",
  "order_id": "GPA.3341-8910-1122-33445"
}
```
- **Response `200 OK`:** Returns upgraded subscription details.

---

## 7. App Configuration & Remote Control

### `GET /app/config`
Remote config payload checked on mobile app launch.
- **Response `200 OK`:**
```json
{
  "status": "success",
  "data": {
    "min_supported_version": 100,
    "latest_version": 102,
    "force_update": false,
    "maintenance_mode": false,
    "maintenance_message": null,
    "features": {
      "enable_wireguard": false,
      "enable_split_tunneling": true,
      "enable_custom_sni": true,
      "enable_in_app_chat": false
    },
    "urls": {
      "privacy_policy": "https://rameztunnel.com/privacy",
      "terms_of_service": "https://rameztunnel.com/terms",
      "support_telegram": "https://t.me/RamezTunnelSupport"
    }
  }
}
```

---

## 8. Edge Node Internal API (mTLS / HMAC-SHA256 Authenticated)

Endpoints used exclusively by the Go Node Agent on edge servers.

### `POST /agent/heartbeat`
- **Headers:** `X-Node-Signature: <HMAC_SHA256>`
- **Payload:** `{ "node_id": 12, "cpu_percent": 24, "ram_percent": 41, "active_tunnels": 87 }`

### `GET /agent/sync-users`
- Returns delta list of authorized user UUIDs, credentials, and revoked IDs.

### `POST /agent/report-traffic`
- Submits aggregated batch traffic usage for billing and quota enforcement:
```json
{
  "node_id": 12,
  "window_start": "2026-11-06T17:50:00Z",
  "window_end": "2026-11-06T17:55:00Z",
  "records": [
    { "user_id": 101, "bytes_tx": 4510000, "bytes_rx": 89200000 }
  ]
}
```
