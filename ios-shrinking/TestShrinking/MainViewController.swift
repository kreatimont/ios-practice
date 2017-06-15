
import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public static func initFromXib() -> MainViewController {
        return MainViewController.init(nibName: "MainViewController", bundle: nil)
    }
    
}

