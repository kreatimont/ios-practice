

import UIKit

class AddNoteViewController: UIViewController {

    var presenter: AddNotePresenter!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func instantiate() -> AddNoteViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNoteViewController") as! AddNoteViewController
    }

    @IBAction func addNoteButtonTapped(_ sender: Any) {
    
        if (titleField.text?.isEmpty)! {
            titleField.placeholder = "Required"
            return
        }
        
        if (messageField.text?.isEmpty)! {
            titleField.placeholder = "Required"
            return
        }
        
        let title = titleField.text!
        let message = messageField.text!
        
        self.presenter.didTapAddNoteButton(title: title, message: message)
    }
}

extension AddNoteViewController: AddNoteView {

    
    
}
