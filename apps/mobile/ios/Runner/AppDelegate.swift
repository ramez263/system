import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var vpnBridgeHandler: IosVpnBridgeHandler?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let handler = IosVpnBridgeHandler(messenger: messenger)
      self.vpnBridgeHandler = handler
      VpnHostApiSetup.setUp(binaryMessenger: messenger, api: handler)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "IosVpnBridgeHandler").messenger()
    let handler = IosVpnBridgeHandler(messenger: messenger)
    self.vpnBridgeHandler = handler
    VpnHostApiSetup.setUp(binaryMessenger: messenger, api: handler)
  }
}
