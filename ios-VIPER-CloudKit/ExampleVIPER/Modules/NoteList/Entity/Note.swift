
import Foundation

struct Note {
    
    let title: String
    let message: String
    let timestamp: Date
    
}

enum CkChangesType {
    case create
    case update
    case delete
}
