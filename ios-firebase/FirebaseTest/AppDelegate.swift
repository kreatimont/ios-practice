
import UIKit

import UserNotifications

import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID

import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public static let notificationName = "recievePush"
    let gcmMessageIDKey = "gcm.message_id"
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        Fabric.with([Crashlytics.self])
        
        //start from xib file
        let navVC = UINavigationController.init(rootViewController: MainViewController.initFromXib())

        navVC.isNavigationBarHidden = false
        
        self.window?.rootViewController = navVC
        
        if let navItem = self.window?.rootViewController?.navigationItem {
            print("navItem exist")
            navItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainViewController.addTrip(_:))), animated: false)
        }

        return true
    }
    
    //MARK: proceed push body and send it to ViewController
    func handleFBNotification(userData: [AnyHashable: Any]) {
        print("\t*handleFBNotification*")
        print("\t\(userData)")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppDelegate.notificationName), object: nil, userInfo: userData)
    }
    
    //MARK: recieving messages
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID [with UIBackgroundFetchResult]: \(messageID)")
        }
        
        handleFBNotification(userData: userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //MARK: refresh token
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    //MARK: fcm connecting
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
        // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
        // the InstanceID token.
        
        // With swizzling disabled you must set the APNs token here.
        // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }
    
    //MARK: reconnect to FCM
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    
    //MARK: disconnect from FCM
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
}

//MARK: ios_10_message_handling
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID [ios10]: \(messageID)")
        }
        
        handleFBNotification(userData: userInfo)
    
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
}

//MARK: ios_10_data_message_handling
extension AppDelegate: FIRMessagingDelegate {
    
    public func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("Message revieved[ios10 FCM]")
        handleFBNotification(userData: remoteMessage.appData);
    }
    
}
