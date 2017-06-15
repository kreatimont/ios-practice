
protocol NoteViewEventHandler {
    func didTapShowNoteButton()
    func didTapAddNoteButton()
}

protocol NoteInteractorOutput: class {
    func receiveNotesList(noteData: [Note])
    func receiveNote(note: Note)
}

class NotePresenter {
    
    weak var view: NoteView!
    var presenter: NotePresenter!
    var interactor: NoteInteractor!
    var router: NoteRouter!
    
    func viewDidLoad() {
        self.interactor.subscribeForChanges()
    }
    
    func viewWillAppear() {
        self.interactor.provideNoteData()
    }

}

extension NotePresenter: NoteInteractorOutput {
    
    func receiveNotesList(noteData: [Note]) {
        view.setNotesList(notes: noteData)
    }
    
    func receiveNote(note: Note) {
        view.appendNote(note: note)
    }
    
}

extension NotePresenter: NoteViewEventHandler {
    
    func didTapShowNoteButton() {
        self.interactor.provideNoteData()
    }
    
    func didTapAddNoteButton() {
        self.router.presentAddNote()
    }
    
}
