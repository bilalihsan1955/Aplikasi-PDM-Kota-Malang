import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "pdm_malang/external_browser",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "openUrl",
              let urlString = call.arguments as? String,
              let url = URL(string: urlString) else {
          result(false)
          return
        }
        UIApplication.shared.open(
          url,
          options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: false]
        ) { success in
          result(success)
        }
      }
    }

    return ok
  }
}
