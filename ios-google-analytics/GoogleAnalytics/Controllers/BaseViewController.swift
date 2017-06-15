
class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(self.title ?? "title not cinfigure") viewWillAppear")
        
        let name = "~\(self.title ?? "title not configure")"
        
        // The UA-XXXXX-Y tracker ID is loaded automatically from the
        // GoogleService-Info.plist by the `GGLContext` in the AppDelegate.
        // If you're copying this to an app just using Analytics, you'll
        // need to configure your tracking ID here.
        
        // [START screen_view_hit_swift]
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            print("Default tracker doesn`t exist")
            return
        }
    
        tracker.set(kGAIScreenName, value: name)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else {
            print("GAIBuilder was not created")
            return
        }
        
        tracker.send(builder.build() as [NSObject : AnyObject])
        // [END screen_view_hit_swift]
        print("data sended")
    }
    
}
