import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Explicit engine: registered and run BEFORE the scene connects so
  // platformTaskRunner is non-nil by FlutterViewController.viewDidLoad —
  // guards against the null deref in
  // -[VSyncClient initWithTaskRunner:callback:] (flutter/flutter#190030).
  let engine = FlutterEngine(name: "lakhsly")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1. تسجيل جميع بلحينات Flutter على المحرك المملوك (قبل التشغيل كالقالب الكلاسيكي)
    GeneratedPluginRegistrant.register(with: engine)

    // 2. تشغيل المحرك بشكل صريح قبل اتصال المشهد
    if !engine.run() {
      NSLog("[Lakhsly] FlutterEngine.run failed (shell not created)")
    }

    // 3. جذر الواجهة - يتبنّاه FlutterSceneDelegate تلقائياً عند اتصال المشهد
    let rootViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    self.window = window

    // 4. تعيين تفويض الإشعارات بأمان بدون طلب APNs المباشر
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // معالجة إظهار الإشعارات والتطبيق يعمل في المقدمة
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .badge, .sound])
  }

  // معالجة الضغط على الإشعار
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("Notification tapped: \(userInfo)")
    completionHandler()
  }
}
