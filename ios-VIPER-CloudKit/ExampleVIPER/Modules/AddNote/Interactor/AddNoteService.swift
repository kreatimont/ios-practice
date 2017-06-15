
import Foundation
import CloudKit


protocol AddNoteServiceDelegate {
    func recordingFinished(error: Error?)
}

class AddNoteService {
    
    static let shared = AddNoteService()
    
    private init() {
    }
    
    func writeRecordToCloudKit(title: String, message: String, timestamp: Date, delegate: AddNoteServiceDelegate) {
        
        let record = CKRecord(recordType: "Note")
        record.setValue(title, forKey: "title")
        record.setValue(message, forKey: "message")
        record.setValue(timestamp, forKey: "timestamp")
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.save(record) { (record, error) in
            delegate.recordingFinished(error: error)
        }
        
    }
    
}
