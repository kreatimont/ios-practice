
import UIKit

class RootRouter {
    
    func presentNoteScreen(in window: UIWindow) {
        window.makeKeyAndVisible()
        window.rootViewController = NoteRouter.assembleModule()
    }
    
}
