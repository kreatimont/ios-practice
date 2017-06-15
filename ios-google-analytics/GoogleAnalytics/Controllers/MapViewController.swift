
import GoogleMaps
import CoreLocation

class MapViewController: BaseViewController {
    
    @IBOutlet weak var gmsMapView: GMSMapView!
    @IBOutlet weak var positionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MapViewController"
        
        self.locationManager.delegate = self
        self.gmsMapView.delegate = self
        
        self.gmsMapView.mapType = .hybrid
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
     
        drawRoute(from: CLLocationCoordinate2D.init(latitude: 51.479369, longitude: 31.264736), to: CLLocationCoordinate2D.init(latitude: 51.495716, longitude: 31.301752), withMode: "driving")
     
    }
    
    func drawRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, withMode: String) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&sensor=false&mode=\(withMode)")
        
        let task = session.dataTask(with: url!) { (data, response, error) in
            
            print("URL: \(url)")
            
            if error != nil {
                print(error?.localizedDescription ?? "error")
            } else {
                
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String : Any] {
                        if let routes = json["routes"] as? [Any] {
                            if let data = routes[0] as? [String : Any] {
                                if let overviewPolyline = data["overview_polyline"] as? [String : Any] {
                                    if let points = overviewPolyline["points"] as? String {
                                        
                                        DispatchQueue.main.async {
                                            let path = GMSPath(fromEncodedPath: points)
                                            let polyline = GMSPolyline(path: path)
                                            polyline.strokeWidth = 2
                                            polyline.strokeColor = .magenta
                                            polyline.map = self.gmsMapView
                                            
                                            let markerFrom = GMSMarker(position: from)
                                            markerFrom.icon = GMSMarker.markerImage(with: .red)
                                            markerFrom.title = "Home"
                                            markerFrom.map = self.gmsMapView
                                            
                                            let markerTo = GMSMarker(position: to)
                                            markerTo.icon = GMSMarker.markerImage(with: .green)
                                            markerTo.title = "Office"
                                            markerTo.map = self.gmsMapView
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    func updateCurrentPosition(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            
            if let position = response?.firstResult() {
                
                let lines = position.lines! as [String]
                self.positionLabel.text = lines.joined(separator: "\n")
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
                
            }
        
        }
        
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            gmsMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
            
            let markerMe = GMSMarker(position: location.coordinate)
            markerMe.icon = GMSMarker.markerImage(with: .yellow)
            markerMe.title = "Me"
            markerMe.map = gmsMapView
            
            gmsMapView.isMyLocationEnabled = true
            gmsMapView.settings.myLocationButton = true
            
            locationManager.stopUpdatingLocation()
        }
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateCurrentPosition(coordinate: position.target)
    }
    
}
