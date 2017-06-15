
protocol AddNoteViewEventHandler {
    func didTapAddNoteButton(title: String, message: String)
}

protocol AddNoteInteractorOutput: class {
    
    func cloudKitRecordingFinished(error: Error?)
}

class AddNotePresenter {
    
    weak var view: AddNoteView!
    var interactor: AddNoteInteractor!
    var router: AddNoteRouter!
    
}

extension AddNotePresenter: AddNoteInteractorOutput {
    
    func cloudKitRecordingFinished(error: Error?) {
        if(error != nil) {
            print(error?.localizedDescription ?? "")
            return
        } else {
            self.router.showNotesList()
        }
    }
 
}

extension AddNotePresenter: AddNoteViewEventHandler {
    
    func didTapAddNoteButton(title: String, message: String) {
        self.interactor.writeRecordToCloudKit(title: title, message: message)
    }
  
}
