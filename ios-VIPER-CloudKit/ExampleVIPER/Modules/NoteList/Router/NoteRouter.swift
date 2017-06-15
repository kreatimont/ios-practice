
import UIKit
import Foundation

class NoteRouter {
    
    weak var noteViewController: NoteViewController!
    
    static func assembleModule() -> UIViewController {
        
        let view = NoteViewController.instantiate()
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
        let addNoteModuleViewController = AddNoteRouter.assembleModule()
        noteViewController.navigationController?.pushViewController(addNoteModuleViewController, animated: true)
    }
    
}
