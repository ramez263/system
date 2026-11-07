import NetworkExtension
import Foundation
import os.log

/// Apple NetworkExtension Packet Tunnel Provider for Ramez Tunnel Plus.
/// Runs in a dedicated sandboxed extension process isolated from the main Flutter Runner.
class PacketTunnelProvider: NEPacketTunnelProvider {

    private let log = OSLog(subsystem: "com.ramez.tunnel_plus.PacketTunnel", category: "TunnelCore")
    private var isTunnelRunning = false
    private var bytesIn: UInt64 = 0
    private var bytesOut: UInt64 = 0
    private var connectionStartTime: Date?

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("Starting Ramez Packet Tunnel Provider...", log: self.log, type: .info)

        // 1. Extract Profile Options Passed from Runner
        let conf = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration
        let serverAddress = (conf?["serverAddress"] as? String) ?? (options?["serverAddress"] as? String) ?? "127.0.0.1"
        let protocolType = (conf?["protocol"] as? String) ?? (options?["protocol"] as? String) ?? "openvpn"
        let dnsServers = (conf?["dnsServers"] as? [String]) ?? (options?["dnsServers"] as? [String]) ?? ["1.1.1.1", "8.8.8.8"]

        // 2. Determine MTU based on protocol (1420 for WireGuard overhead, 1500 for OpenVPN/SSH)
        let mtu: NSNumber = (protocolType.lowercased() == "wireguard") ? 1420 : 1500

        // 3. Configure Tunnel Network Settings
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverAddress)

        // IPv4 Settings (Local virtual tunnel IP & default routing)
        let ipv4Settings = NEIPv4Settings(addresses: ["10.8.0.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings

        // DNS Settings
        let dnsSettings = NEDNSSettings(servers: dnsServers)
        dnsSettings.matchDomains = [""] // Route all DNS through tunnel to prevent DNS leaks
        networkSettings.dnsSettings = dnsSettings

        // MTU
        networkSettings.mtu = mtu

        // 4. Apply Network Settings to OS TUN interface
        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                os_log("Failed to set tunnel network settings: %{public}@", log: self.log, type: .error, error.localizedDescription)
                completionHandler(error)
                return
            }

            self.isTunnelRunning = true
            self.connectionStartTime = Date()
            self.bytesIn = 0
            self.bytesOut = 0

            os_log("Tunnel network settings applied successfully. MTU: %{public}@", log: self.log, type: .info, mtu)

            // Start reading packets from the OS virtual TUN interface
            self.readPacketsLoop()

            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Stopping tunnel with reason: %{public}d", log: self.log, type: .info, reason.rawValue)
        isTunnelRunning = false
        connectionStartTime = nil
        completionHandler()
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        guard let message = String(data: messageData, encoding: .utf8) else {
            completionHandler?(nil)
            return
        }

        switch message {
        case "GET_STATS":
            let duration = connectionStartTime.map { Int(Date().timeIntervalSince($0)) } ?? 0
            let stats: [String: Any] = [
                "bytesIn": bytesIn,
                "bytesOut": bytesOut,
                "durationSeconds": duration,
                "isRunning": isTunnelRunning
            ]
            if let responseData = try? JSONSerialization.data(withJSONObject: stats, options: []) {
                completionHandler?(responseData)
            } else {
                completionHandler?(nil)
            }
        case "PING":
            completionHandler?("PONG".data(using: .utf8))
        default:
            completionHandler?(nil)
        }
    }

    // Packet processing loop reading from OS TUN interface
    private func readPacketsLoop() {
        guard isTunnelRunning else { return }

        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self, self.isTunnelRunning else { return }

            for packet in packets {
                self.bytesOut += UInt64(packet.count)
            }

            // In production integration with native sing-box/wireguard/openvpn C-core,
            // packets are handed directly to the core tunnel ring buffer.
            // Loop for next batch of packets:
            self.readPacketsLoop()
        }
    }
}
