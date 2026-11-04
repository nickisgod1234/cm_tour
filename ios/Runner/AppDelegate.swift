import FirebaseCore
import FirebaseMessaging
import Flutter
import UIKit
import UserNotifications

fileprivate var pendingApnsToken: Data?
fileprivate var lastApnsError: String?
fileprivate var pushChannelInstalled = false

fileprivate func deliverApnsToken() {
  guard let token = pendingApnsToken, FirebaseApp.app() != nil else { return }
  Messaging.messaging().setAPNSToken(token, type: .unknown)
  pendingApnsToken = nil
  lastApnsError = nil
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    GeneratedPluginRegistrant.register(with: self)
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    installPushChannel()
    application.registerForRemoteNotifications()
    return launched
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    pendingApnsToken = deviceToken
    deliverApnsToken()
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    lastApnsError = error.localizedDescription
    NSLog("APNs register failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    installPushChannel()
    application.registerForRemoteNotifications()
    deliverApnsToken()
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if notification.request.content.userInfo["gcm.message_id"] != nil {
      completionHandler([.badge])
      return
    }
    completionHandler([.alert, .badge, .sound])
  }

  private func installPushChannel() {
    if pushChannelInstalled { return }
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    pushChannelInstalled = true
    let channel = FlutterMethodChannel(
      name: "cm_tour/push",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "registerApns" {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
          let finish: (String?) -> Void = { message in
            DispatchQueue.main.async {
              UIApplication.shared.registerForRemoteNotifications()
              deliverApnsToken()
              result(message ?? lastApnsError)
            }
          }
          switch settings.authorizationStatus {
          case .denied:
            finish("การแจ้งเตือนถูกปิดในตั้งค่าของ iPhone")
          case .notDetermined:
            center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
              if let error {
                finish(error.localizedDescription)
                return
              }
              finish(granted ? nil : "ยังไม่อนุญาตการแจ้งเตือน")
            }
          default:
            finish(nil)
          }
        }
        return
      }
      result(FlutterMethodNotImplemented)
    }
  }
}
