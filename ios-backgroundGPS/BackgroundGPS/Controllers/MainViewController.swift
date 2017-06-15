
import UIKit

class MainViewController: UIViewController {
 
    @IBOutlet weak var tableView: UITableView!
    
    var locationTracker: ABLocationManager?

    var data = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        
        self.locationTracker = ABLocationManager.shared
        self.locationTracker?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func reloadWithData(newData: Location) {
        self.data.append(newData)
        self.tableView.reloadData()
        
    }
    
    func applicationEnterForeground() {
        self.locationTracker = ABLocationManager.shared
        self.locationTracker?.delegate = self;
        self.reloadWithData(newData: (self.locationTracker?.getLocations())!.last!)
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier) as! LocationCell
        
        cell.locationCoordinates.text = "Longtitude: \(self.data[indexPath.row].longtitude); Latitude \(self.data[indexPath.row].latitude)"
        cell.locationTime.text = "Time: \(self.data[indexPath.row].fixingTime)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
}

extension MainViewController: ABLocationManagerDelegate {
    
    func didUpdateLocation(_ location: Location) {
        ApiManager.shared.postCurrentLocation(lat: location.latitude, long: location.longtitude)
        self.reloadWithData(newData: location)
    }
    
}

