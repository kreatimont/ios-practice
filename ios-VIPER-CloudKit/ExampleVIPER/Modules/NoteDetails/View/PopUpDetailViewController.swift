
import UIKit

class PopUpDetailViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelMessage: UITextView!
    @IBOutlet weak var labelDate: UILabel!
    
    static func instantiate() -> NoteViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopUpNoteDetailViewController") as! NoteViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
}

extension NoteViewController: NoteDetailsView {
    
    func setNoteData(note: Note) {
        
    }
    
}
