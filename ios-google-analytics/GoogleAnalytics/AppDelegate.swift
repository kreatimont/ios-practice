
import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dispatchHandler: ((_ result: GAIDispatchResult) -> Void)? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureGoogleAnalytics()
        configureGoogleMapsServices()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.sendHintsInBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        GAI.sharedInstance().dispatchInterval = 120
    }
    
    func configureGoogleMapsServices() {
        if let path = Bundle.main.path(forResource: "secrets", ofType: "plist") {
            if let keys = NSDictionary(contentsOfFile: path) {
                if let googleMapApiKey = keys.value(forKey: "map_api_key") as! String! {
                    GMSServices.provideAPIKey(googleMapApiKey)
                }
            }
        }
    }
    
    func configureGoogleAnalytics() {
        
        // [START tracker_swift]
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if(configureError == nil) {
            print("Error configuring Google services: \(configureError)")
            return
        }
        
        // Optional: configure GAI options.
        if let gai = GAI.sharedInstance() {
            gai.trackUncaughtExceptions = true  // report uncaught exceptions
            gai.logger.logLevel = GAILogLevel.info
        } else {
             print("Google Analytics not configured correctly")
        }
        // [END tracker_swift]
    }
    
    func sendHintsInBackground() {
        
        var taskExpired = false
        let taskId = UIApplication.shared.beginBackgroundTask { 
            taskExpired = true
        }
        if taskId == UIBackgroundTaskInvalid {
            return;
        }
        self.dispatchHandler = { (_ result: GAIDispatchResult) -> Void in
            // Send hits until no hits are left, a dispatch error occurs, or
            // the background task expires.
            if result == GAIDispatchResult.good && !taskExpired {
                GAI.sharedInstance().dispatch(completionHandler: self.dispatchHandler)
            } else {
                UIApplication.shared.endBackgroundTask(taskId)
            }
        }
        
        GAI.sharedInstance().dispatch(completionHandler: self.dispatchHandler)

    }

}

