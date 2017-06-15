
import UIKit

class NoteViewController: UIViewController {
    
    var presenter: NotePresenter!
    
    @IBOutlet weak var notesTableView: UITableView!
    
    var notes: [Note] = [] {
        didSet {
            notesTableView.reloadData()
        }
    }
    
    static func instantiate() -> NoteViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.viewWillAppear()
    }
    
    @IBAction func addNoteButtonTapped(_ sender: Any) {
        self.presenter.didTapAddNoteButton()
    }
   
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.presenter.didTapShowNoteButton()
    }
    
    func setupView() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
    }
    
}

extension NoteViewController: NoteView {
    
    func setNotesList(notes: [Note]) {
        self.notes = notes
    }
    
    func appendNote(note: Note) {
        self.notes.append(note)
    }
    
}

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.id, for: indexPath) as! NoteTableViewCell
        
        cell.noteLabel.text = "\(notes[indexPath.row].title)\n\(notes[indexPath.row].message)\n\(notes[indexPath.row].timestamp)"
        
        return cell
    }
    
}

