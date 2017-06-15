
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var pass: UILabel!
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        email.text = userDefaults.value(forKey: ViewController.emailKey) as! String?
        pass.text = userDefaults.value(forKey: ViewController.passKey) as! String?
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "logout" {
            userDefaults.removeObject(forKey: ViewController.emailKey)
            userDefaults.removeObject(forKey: ViewController.passKey)
        }
        
    }
    
}
