import UIKit
import Flutter
import FirebaseCore 
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate,MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
     if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self
     }
  
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      
      
       Messaging.messaging().delegate = self
       let token = Messaging.messaging().fcmToken ?? "none"
       print("FCM TOKEN", token)
      
       return super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
     }
    
     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
         print("FCM TOKEN", fcmToken!)
     }
}