
import UIKit
import PhoneNumberKit
import AKNumericFormatter

class ViewController: UIViewController {


    @IBOutlet weak var akTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var currentCountry: UITextField!
    
    let placeholder: UniChar = 42
    let phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(textFieldDidChangeValue(textField:)), for: .editingChanged)
        self.akTextField.numericFormatter = AKNumericFormatter.init(mask: "+(***) ** *** ****", placeholderCharacter: placeholder)
        self.akTextField.placeholder = "+(***) ** *** ****"
    }
    
    @IBAction func btnTapped(_ sender: Any) {
     
        guard let btnSend = sender as? UIButton else {
            return
        }
        
        var region: String
        var regionMask: String
        
        switch btnSend.tag {
        case 0:
            region = "UA"
            regionMask = "+(***) ** *** ****"
        case 1:
            region = "GB"
            regionMask = "+(**) *-*-*-*-*-*****"
        case 2:
            region = "US"
            regionMask = "+(*) *-****-******"
        default:
            region = "UA"
            regionMask = "+(***) ** *** ****"
        }
        
        do {
            print("current region: \(region)")
            let phoneNumber = try phoneNumberKit.parse(textField.text!, withRegion: region)
            print("\(String(describing: phoneNumber))")
        } catch {
            print("Generic parser error")
        }
        self.akTextField.text = AKNumericFormatter.formatString(akTextField.text, usingMask: regionMask, placeholderCharacter: placeholder)
        self.akTextField.numericFormatter = AKNumericFormatter.init(mask: regionMask, placeholderCharacter: placeholder)
        self.akTextField.placeholder = regionMask
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidChangeValue(textField: UITextField) {
        do {
            let phoneNumber = try phoneNumberKit.parse(textField.text!)
            currentCountry.text = phoneNumberKit.mainCountry(forCode: phoneNumber.countryCode)
            currentCountry.text = "Country id:\(phoneNumberKit.mainCountry(forCode: phoneNumber.countryCode)!),type: \(phoneNumber.type), country code: \(phoneNumber.countryCode);"
        } catch {
            print("Generic parser error")
        }
    }
    
}

