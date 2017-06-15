
import UIKit
import Foundation

class AddNoteRouter {
    
    weak var addNoteViewController: AddNoteViewController!
    
    static func assembleModule() -> UIViewController {
        
        let view = AddNoteViewController.instantiate()
        let presenter = AddNotePresenter()
        let interactor = AddNoteInteractor()
        let router = AddNoteRouter()
    
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        router.addNoteViewController = view
        
        return view
        
    }
    
    func showNotesList() {
        _ = self.addNoteViewController.navigationController?.popToRootViewController(animated: true)
    }
    
}
