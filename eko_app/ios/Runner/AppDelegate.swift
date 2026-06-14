import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  // code inspired by https://github.com/MatheusHenriq/PushNotificationFlutteriOS/blob/main/ios/Runner/AppDelegate.swift
  let channelName : String = "PushNotificationChannel"
  var deviceToken : String = ""
  private var pushNotificationChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let messenger = (window?.rootViewController as? FlutterViewController)?.binaryMessenger
      ?? registrar(forPlugin: channelName)?.messenger()
    if let messenger = messenger {
      pushNotificationChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    }
    
    if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    pushNotificationChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {
        case "requestNotificationPermissions":
            self?.requestNotificationPermissions(result: result)
        case "registerForPushNotifications":
            self?.registerForPushNotifications(application: application, result: result)
        case "retrieveDeviceToken":
            self?.getDeviceToken(result: result)
        case "getAppGroupPath":
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.untitledApp") {
                result(url.path)
            } else {
                result(FlutterError(code: "APP_GROUP", message: "App Group container not found", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

      override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceToken = token
    }

    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    private func requestNotificationPermissions(result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            result(FlutterError(code: "PERMISSION_ERROR", message: "Failed to request permissions", details: error.localizedDescription))
            return
        }
            result(granted)
        }
    }

    private func registerForPushNotifications(application: UIApplication, result: @escaping FlutterResult) {
        application.registerForRemoteNotifications()
        result("Device Token registration initiated")
    }

    private func getDeviceToken(result: @escaping FlutterResult) {
        if(deviceToken.isEmpty){
            result(FlutterError(code: "UNAVAILABLE", message: "Device token not available", details: nil))
        } else{
            result(deviceToken)
        }
    }

    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
         } else {
             completionHandler([.alert, .sound, .badge])
         }
     }
    
   override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo: userInfo)
        completionHandler()
    }

    private func handleNotification(userInfo: [AnyHashable: Any]) {
        if pushNotificationChannel == nil {
            let messenger = (window?.rootViewController as? FlutterViewController)?.binaryMessenger
              ?? registrar(forPlugin: channelName)?.messenger()
            if let messenger = messenger {
                pushNotificationChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
            }
        }
        let payload = userInfo.reduce(into: [String: Any]()) { result, entry in
            if let key = entry.key as? String {
                result[key] = entry.value
            }
        }
        if !payload.isEmpty {
            pushNotificationChannel?.invokeMethod("onPushNotification", arguments: payload)
        }
    }

}
