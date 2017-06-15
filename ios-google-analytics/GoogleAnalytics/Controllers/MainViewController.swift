
import UIKit

class MainViewController: BaseViewController {

    @IBOutlet weak var btnSendEvent: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MainViewController"
        btnSendEvent.addTarget(self, action: #selector(btnSendEventTapped(sender:)), for: UIControlEvents.touchDown)
        btnSendEvent.layer.cornerRadius = 6.0
    }
    
    func btnSendEventTapped(sender: Any?) {
        print("btnSendTapped")
        guard let tracker = GAI.sharedInstance().defaultTracker  else {
            return
        }
        guard let event = GAIDictionaryBuilder.createEvent(withCategory: "Action", action: "Share", label: nil, value: nil) else {
            return
        }
        
        event.set(GAIFields.customMetric(for: 1), forKey: "my custom value")
        tracker.send(event.build() as [NSObject : AnyObject])
        print("tracker sent event")
    }
    
}
