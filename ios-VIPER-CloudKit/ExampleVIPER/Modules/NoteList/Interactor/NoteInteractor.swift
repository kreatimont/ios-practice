
import Foundation
import CloudKit

protocol NoteProvider {
    func provideNoteData()
}

class NoteInteractor: NoteProvider {
    
    weak var output: NoteInteractorOutput!
    
    init() {
        //subscribe on remote notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecieveCkRemoteNotification(_:)), name: Notification.Name.init(rawValue: AppDelegate.ckRemoteNotificationId), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRecievePusherNotification(_:)), name: Notification.Name.init(AppDelegate.pusherNotificationId), object: nil)
    }
    
    deinit {
        //unsubscribe on remote notification
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didRecievePusherNotification(_ notification: Notification) {
        
        if let userData = notification.userInfo {
            if let note = userData["note"] as? Note {
                AddNoteService.shared.writeRecordToCloudKit(title: note.title, message: note.message, timestamp: note.timestamp, delegate: self)
            } else {
                print("failed to resolve note data")
            }
        }
        
    }
    
    @objc func didRecieveCkRemoteNotification(_ notification: Notification) {
        
        if let userData = notification.userInfo {
            if let type = userData["type"] as? CkChangesType {
                switch type {
                    case .create:
                        break;
                    case .update:
                        break;
                    case .delete:
                        break;
                }
                provideNoteData()
            } else {
                print("failed to resolve type")
            }
        }
        
    }
    
    func provideNoteData() {
        getAllRecordsFromCloudKit()
    }
    
    func subscribeForChanges() {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let ckSubscription = CKSubscription(recordType: "Note", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
        publicDatabase.save(ckSubscription, completionHandler: { (subs, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "subs error")
                return
            }
            print("Subscription saved(<ios9)")
        })
    
    }
    
    func getAllRecordsFromCloudKit() {
        
        let cloudKitContainer = CKContainer.default()
        let publicDatabase = cloudKitContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { ( records, error) in
            
            if error != nil {
                print("Error: \(error?.localizedDescription)")
                return
            }
            
            if let resultRecords = records {
                
                var noteData: [Note] = []
                
                for record in resultRecords {
                    
                    let title: String = record.value(forKey: "title") as! String
                    let message: String = record.value(forKey: "message") as! String
                    let timestamp: Date = record.value(forKey: "timestamp") as! Date
                    
                    noteData.append(Note(title: title, message: message, timestamp: timestamp))
                    
                }
                OperationQueue.main.addOperation({
                    self.output.receiveNotesList(noteData: noteData)
                })
            }
        }
        
    }
    
    func getRecordByOneFromCloudKit() {
        
        let cloudKitContainer = CKContainer.default()
        let publicDatabase = cloudKitContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 20
        
        queryOperation.recordFetchedBlock = { (record: CKRecord!) in
            if (record) != nil {
                self.output.receiveNote(note: self.convertCkRecordToNote(record: record))
            }
        }
        
        publicDatabase.add(queryOperation)
    }
    
    
    func convertCkRecordToNote(record: CKRecord) -> Note {
        let title: String = record.value(forKey: "title") as! String
        let message: String = record.value(forKey: "message") as! String
        let timestamp: Date = record.value(forKey: "timestamp") as! Date
        
        return Note(title: title, message: message, timestamp: timestamp)
    }
    
}

extension NoteInteractor: AddNoteServiceDelegate {
    func recordingFinished(error: Error?) {
        if(error != nil) {
            print(error?.localizedDescription ?? "NoteInteractor: recordingFinished error")
        } else {
            OperationQueue.main.addOperation {
                self.provideNoteData()
            }
        }
    }
}
