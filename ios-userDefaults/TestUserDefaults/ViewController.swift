

import UIKit

class ViewController: UIViewController {

    static let emailKey = "email"
    static let passKey = "pass"
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidAppear(_ animated: Bool) {
        if let userEmail = userDefaults.value(forKey: ViewController.emailKey) {
            print("user \(userEmail) exist")
            performSegue(withIdentifier: "login", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didLoginClicked(_ sender: Any) {
        
        let stringEmail = email.text ?? "defEmail"
        let stringPass = pass.text ?? "defPass"
        handleLoginAction(email: stringEmail, pass: stringPass)
        
        performSegue(withIdentifier: "login", sender: self)
        
    }
    
    func handleLoginAction(email: String, pass: String) {
        
        if let userEmail = userDefaults.value(forKey: email) {
            
            print("existing email: \(userEmail)")
            
            if let userPass = userDefaults.value(forKey: pass) {
                print("existing pass: \(userPass)")
                performSegue(withIdentifier: "login", sender: self)
            }
            //show alert
            print("pass not confirm")
        } else {
            userDefaults.setValue(email,forKey: ViewController.emailKey)
            userDefaults.setValue(pass, forKey: ViewController.passKey)
            performSegue(withIdentifier: "login", sender: self)
        }
        
    }
    
}

