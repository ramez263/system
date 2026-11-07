# Ramez Tunnel Plus — Production Runbook & Operations Manual
**Platform:** Flutter Mobile (Android First) + Laravel Control Plane  
**Version:** 1.0.0  
**Target Environment:** Staging & Production

---

## 1. Release Signing & App Bundle Automation

### A. Android Keystore Creation
Execute in a secure offline environment to generate the release signing key:
```bash
keytool -genkey -v -keystore apps/mobile/android/app/release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ramez_release_key
```

### B. `key.properties` Setup
Create `apps/mobile/android/key.properties` (never commit to git):
```properties
storePassword=SECURE_KEYSTORE_PASSWORD
keyPassword=SECURE_ALIAS_PASSWORD
keyAlias=ramez_release_key
storeFile=release.jks
```

### C. Release Build Execution with Obfuscation & Symbols Splitting
To produce a hardened Android App Bundle (AAB) for Google Play Console Internal Track:
```powershell
cd apps/mobile
flutter build appbundle --release `
  --obfuscate `
  --split-debug-info=./build/app/outputs/symbols `
  --target=lib/main_prod.dart
```

To produce universal or split release APKs for testing on physical devices:
```powershell
cd apps/mobile
flutter build apk --release `
  --split-per-abi `
  --obfuscate `
  --split-debug-info=./build/app/outputs/symbols `
  --target=lib/main_prod.dart
```

---

## 2. Server Edge Nodes & Credential Rotation Runbook

### A. Node Health Checks & Automated Degradation
The Laravel control plane runs `ServerProbeService` every 2 minutes:
- WireGuard nodes are probed via UDP handshake test on port 51820.
- SSH nodes are probed via socket connection on port 22.
- OpenVPN nodes are probed via socket connection on port 1194.
- If a server fails 3 consecutive probes, its status is updated to `offline` and automatically omitted from the mobile client catalog.

### B. Emergency Key Rotation Procedure
If a server's private key or master credentials are suspected of being compromised:
1. **Access Control Plane Admin:** Navigate to **Admin Panel > Servers > Server Details**.
2. **Trigger Key Rotation:** Click **"Rotate Node Keys"** button.
3. **Automated Action:**
   - Laravel generates a fresh 32-byte Ed25519 / WireGuard keypair.
   - Pushes updated configuration to edge node via Node Agent over mTLS.
   - Updates `servers` table with new public key.
   - Emits a real-time Reverb broadcast event (`ServerCatalogUpdated`) triggering mobile apps to re-sync server certificates.

---

## 3. Incident Response Playbooks

### Playbook 1: Server IP Blocked by Carrier / Firewall
- **Symptoms:** High connection failure rate or packet loss reported in `connection_telemetries`.
- **Immediate Mitigation:**
  1. Login to Filament Admin Panel > Servers.
  2. Toggle the affected server to **Disabled** to immediately divert new client connections.
  3. Spin up standby node IP on alternative cloud provider (e.g. OVH or Hetzner).
  4. Run Ansible node provisioning playbook (`infra/ansible/provision-node.yml`).
  5. Add new server entry to Admin Panel.

### Playbook 2: Distributed Denial of Service (DDoS) on Control Plane
- **Symptoms:** High HTTP 502/504 errors on `/api/v1/*`.
- **Immediate Mitigation:**
  1. Enable Cloudflare Under Attack Mode on `api.rameztunnel.com`.
  2. The mobile client's `RetryInterceptor` will automatically back off using exponential jitter (1s, 2s, 4s).
  3. Verify Redis rate limiter is actively throttling abusive device identifiers (`throttle:120,1`).

### Playbook 3: Database Restore & Disaster Recovery
- **Backup Location:** Nightly automated backups stored in S3/MinIO bucket `s3://ramez-backups/mysql/`.
- **Restoration Command:**
  ```bash
  docker compose exec -T db mysql -u root -p"$DB_PASSWORD" ramez_tunnel < backup_latest.sql
  docker compose exec backend php artisan migrate --force
  docker compose exec backend php artisan cache:clear
  ```

---

## 4. Google Play Release Checklist

- [x] Application name set to `Ramez Tunnel Plus` in `AndroidManifest.xml`.
- [x] Cleartext traffic prohibited and Certificate Pinning active in `network_security_config.xml`.
- [x] `FLAG_SECURE` toggled on sensitive screens.
- [x] R8 ProGuard rules keep native VPN engines and strip debugging logs.
- [x] Google Play VPN Service Declaration submitted.
- [x] Google Play Data Safety form completed.
- [x] Zero-Logs Privacy Policy live and linked in store listing and app.
- [x] Signed App Bundle built with `--obfuscate --split-debug-info`.
