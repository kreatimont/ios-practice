
import UIKit
import Foundation

class NoteDetailsRouter {
    
    weak var noteDetailsViewController: PopUpDetailViewController!
    
    static func assembleModule() -> UIViewController {
        
        let view = PopUpDetailViewController.instantiate()
        let presenter = NotePresenter()
        let interactor = NoteInteractor()
        let router = NoteRouter()
        
        let navigation = UINavigationController(rootViewController: view)
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.output = presenter
        
        router.noteViewController = view
        
        return navigation
        
    }
    
    func presentAddNote() {
        self.noteDetailsViewController.view.removeFromSuperview()
    }

    
}
