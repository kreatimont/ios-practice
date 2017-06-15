
import AFNetworking

class ApiManager {
    
    enum ApiEntity {
        case trips
        case cities
    }
    
    static let shared = ApiManager()
    
    var manager: AFHTTPSessionManager {
        
        let _manager = AFHTTPSessionManager()
        _manager.responseSerializer = AFHTTPResponseSerializer()
        return _manager
    }
    
    let requestBinBase = "http://requestb.in/1mkk9qf1"
    
    func postCurrentLocation(lat: Double, long: Double) {
        
        manager.post("\(requestBinBase)?lat=\(String(lat))/&long=\(String(long))", parameters: nil, progress: nil,
                     
            success: { (operation, responseObject) in
                print("postCurrentLocation success")
                
        }, failure: { (operation, error) in
                print("Url: \(self.requestBinBase)?lat=\(String(lat))&long=\(String(long))")
                print("postCurrentLocation failure, error: \(error.localizedDescription)")
        })
        
    }
    
}
