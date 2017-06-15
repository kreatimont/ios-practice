
import UIKit
import FirebaseCore
import FirebaseDatabase
import Crashlytics

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataList = [Trip]()
    
    //MARK: FB data keys
    let fbFrom = "FBfrom"
    let fbTo = "FBto"
    let fbDate = "FBdate"
    
    static var isXib = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        let nib = UINib(nibName: "TripCellXibg", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: TripCell.idXib)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleFBUserData(_:)), name: NSNotification.Name(rawValue: AppDelegate.notificationName), object: nil)
        
        loadTripFromFirebase()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func handleFBUserData(_ notification: Notification) {
        
        if let recievedUserData = notification.userInfo {
        
            let optFrom = recievedUserData[fbFrom]
            let optTo = recievedUserData[fbTo]
            let optDate = recievedUserData[fbDate]
            
            if (optFrom != nil && optTo != nil && optDate != nil) {
                let post: [String: String] = ["from": optFrom! as! String, "to": optTo! as! String, "date": optDate! as! String]
                
                let databaseRef = FIRDatabase.database().reference()
                
                databaseRef.child("Trip").childByAutoId().setValue(post, withCompletionBlock: { (error, ref) in
                    if error == nil {
                        print("success")
                    } else {
                        print(error?.localizedDescription ?? "default")
                    }
                    
                })
            } else {
                print("Push notification hasn`t valid body")
            }
        }
    }
    
    public static func initFromXib() -> MainViewController {
        isXib = true
        return MainViewController.init(nibName: "MainViewController", bundle: nil)
    }
    
    @IBAction func addTrip(_ sender: Any) {
        Crashlytics.sharedInstance().setUserEmail("kre@email.com")
        Crashlytics.sharedInstance().crash()
    }
    
    func post() {
        
        let from = "Skellige"
        let to = "Mahakam"
        let date = "1034-02-02"
        
        let post : [String: String] = ["from": from, "to": to, "date": date]
        
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("Trip").childByAutoId().setValue(post) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
            }
        }
    }
    
    func loadTripFromFirebase() {
        let databaseRef = FIRDatabase.database().reference().child("Trip")
  
        databaseRef.observe(.value, with: { (snapshot) in
            
            self.dataList.removeAll()
            
            for trip in (snapshot.children) {
                let snap = trip as! FIRDataSnapshot
                let dict = snap.value as! [String: String]
                
                let newTrip = Trip(from: dict["from"]!, to: dict["to"]!, date: dict["date"]!)
            
                self.dataList.append(newTrip)
                self.tableView.reloadData()
            }
        
        })
    }
   
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TripCell
        
        if MainViewController.isXib {
            cell = tableView.dequeueReusableCell(withIdentifier: TripCell.idXib) as! TripCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: TripCell.id) as! TripCell
        }
        
        cell.layer.cornerRadius = 0.5
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        
        cell.trip.text = "\(dataList[indexPath.row].from) - \(dataList[indexPath.row].to)"
        cell.date.text = "\(dataList[indexPath.row].date)"
        
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
}
