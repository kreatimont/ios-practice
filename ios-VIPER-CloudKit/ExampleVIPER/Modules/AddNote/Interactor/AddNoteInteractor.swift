
import Foundation
import CloudKit


class AddNoteInteractor {
    
    weak var output: AddNoteInteractorOutput!
    
    func writeRecordToCloudKit(title: String, message: String) {
        AddNoteService.shared.writeRecordToCloudKit(title: title, message: message, timestamp: Date(), delegate: self)
    }
    
}

extension AddNoteInteractor: AddNoteServiceDelegate {
    
    func recordingFinished(error: Error?) {
        OperationQueue.main.addOperation {
            self.output.cloudKitRecordingFinished(error: error)
        }
    }
    
}
