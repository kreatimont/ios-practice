
protocol NoteView: class {
    func setNotesList(notes: [Note])
    func appendNote(note: Note)
}
