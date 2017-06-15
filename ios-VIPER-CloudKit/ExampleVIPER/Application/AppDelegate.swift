
import UIKit
import CloudKit
import Foundation
import PusherSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    public static let ckRemoteNotificationId = "ckRemoteNotification"
    public static let pusherNotificationId = "pusherNotification"

    let pusher = Pusher(
        key: "34e3a6454e1f36306bfd",
        options: PusherClientOptions(host: .cluster("eu"))
    )
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        let notificationSettings = UIUserNotificationSettings(types: UIUserNotificationType.alert, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        RootRouter().presentNoteScreen(in: window!)
       
        initPusher()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])

        if cloudKitNotification.notificationType == .query {
            let queryNotification = cloudKitNotification as! CKQueryNotification
            
            if queryNotification.queryNotificationReason == .recordDeleted {
                let userData: [AnyHashable : Any] = ["type": CkChangesType.delete]
                NotificationCenter.default.post(name: Notification.Name.init(rawValue: AppDelegate.ckRemoteNotificationId), object: nil, userInfo: userData)
            } else {
                let database: CKDatabase
                
                if queryNotification.isPublicDatabase {
                    database = CKContainer.default().publicCloudDatabase
                } else {
                    database = CKContainer.default().privateCloudDatabase
                }
                
                database.fetch(withRecordID: queryNotification.recordID!, completionHandler: { (record, error) in
                    
                    guard error == nil else {
                        print(error?.localizedDescription ?? "data was not fetched")
                        return
                    }
                    
                    var ckChangesType: CkChangesType;
                    if queryNotification.queryNotificationReason == .recordUpdated {
                        ckChangesType = CkChangesType.update
                    } else {
                        ckChangesType = CkChangesType.create
                    }
                    
                    let userData: [AnyHashable : Any] = ["record": record!, "type": ckChangesType]
                    NotificationCenter.default.post(name: Notification.Name.init(rawValue: AppDelegate.ckRemoteNotificationId), object: nil, userInfo: userData)

                })
            }
        }
        
    }
    
    func initPusher() {

        let channel = pusher.subscribe("viper-channel")
        
        channel.bind(eventName: "add-note-event") { (data) in
            
            if let data = data as? [String : AnyObject] {
                
                let title = data["title"] as? String
                let message = data["message"] as? String
                let timestamp = data["timestamp"] as? String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd H:m" //server date format
            
                let date = dateFormatter.date(from: timestamp!)! as Date
                
                let newNote = Note(title: title!, message: message!, timestamp: date)
            
                let userData: [AnyHashable : Any] = ["note": newNote]
                
                NotificationCenter.default.post(name: Notification.Name.init(rawValue: AppDelegate.pusherNotificationId), object: nil, userInfo: userData)
            } else {
                print("data was not resolved")
            }
        
        }
        
        pusher.connect()
    }


}

