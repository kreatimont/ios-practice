
import CoreLocation
import Foundation
import UIKit

protocol ABLocationManagerDelegate: NSObjectProtocol {
    
    func didUpdateLocation(_ location: Location)
    
}

class Location {
    
    var latitude: Double
    var longtitude: Double
    var accuracy: Double
    var fixingTime: Date
    
    init(lat: Double, long: Double, acc: Double, time: Date) {
        self.latitude = lat
        self.longtitude = long
        self.accuracy = acc
        self.fixingTime = time
    }
    
}

class ABLocationManager: NSObject, CLLocationManagerDelegate {
    
    var delegate: ABLocationManagerDelegate?
    static let shared = ABLocationManager()
    
    var locations = [Location]()
    
    var timer: Timer?
    var delayTimer: Timer?
    
    var bgTaskIdList = [UIBackgroundTaskIdentifier]()
    
    var masterTaskId = UIBackgroundTaskInvalid
    
    var locationManager: CLLocationManager?
    
    private override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.delegate = self
        
        self.locationManager?.startUpdatingLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicatinEnterBackground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func startTrackingLocation() {
        if CLLocationManager.locationServicesEnabled() == false {
            print("locationServicesEnabled false")
            //show alert
        } else {
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus == .denied || authorizationStatus == .restricted {
                print("authorizationStatus failed")
                //show alert
            } else {
                print("authorizationStatus authorized")
                self.startTracking()
            }
        }
    }
    
    func stopTrackingLocation() {
        self.resetTimer()
        self.locationManager?.stopUpdatingLocation()
    }
    
    func getLocations() -> [Location] {
        return self.locations
    }
    
    func startTracking() {
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.startUpdatingLocation()
    }
    
    func restartTrackingLocation() {
        self.resetTimer()
        self.startTracking()
    }
    
    func resetTimer() {
        if (self.timer != nil) {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func applicatinEnterBackground() {
        self.startTracking()
        _ = self.beginNewBackgroundTask()
    }
    
    func stopTrackingLocationAfterDelay() {
        self.locationManager?.stopUpdatingLocation()
        self.delegate?.didUpdateLocation(self.locations[0])
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("locationManager didUpdateLocations")
        
        for newLocation in locations {
            
            let theLocation = newLocation.coordinate
            let theAccuracy = newLocation.horizontalAccuracy
            let locationAge = newLocation.timestamp.timeIntervalSinceNow
            
            if locationAge > 30.0 {
                continue
            }
            
            //Select only valid location and also location with good accuracy
            if theAccuracy > 0 && theAccuracy < 2000 && (!(theLocation.latitude == 0.0 && theLocation.longitude == 0.0)) {
                
                let locationToSave = Location(lat: theLocation.latitude, long: theLocation.longitude, acc: theAccuracy, time: Date())
                
                //Add the vallid location with good accuracy into an array
                //Every 1 minute, I will select the best location based on accuracy and send to server
                self.locations.append(locationToSave)
            }
        }
        
        //If the timer still valid, return it (Will not run the code below)
        if (self.timer != nil) {
            return
        }
        
        _ = self.beginNewBackgroundTask()
        
        //Restart the locationMaanger after 1 minute
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.restartTrackingLocation), userInfo: nil, repeats: false)
        
        //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
        //The location manager will only operate for 10 seconds to save battery
        if (self.delayTimer != nil) {
            self.delayTimer?.invalidate()
            self.delayTimer = nil
        }
        
        self.delayTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.stopTrackingLocationAfterDelay), userInfo: nil, repeats: false)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error.localizedDescription)")
        //show aler with error
    }
    
    //MARK: Background Task Manager
    
    func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier {
        
        let application = UIApplication.shared
        var bgTaskId = UIBackgroundTaskInvalid
        if application.responds(to: #selector(application.beginBackgroundTask(expirationHandler:))) {
            bgTaskId = application.beginBackgroundTask(expirationHandler: {() -> Void in
                print("background task \(UInt(bgTaskId)) expired")
                self.bgTaskIdList.remove(at: self.bgTaskIdList.index(bgTaskId, offsetBy: 0))
                
                application.endBackgroundTask(bgTaskId)
                bgTaskId = UIBackgroundTaskInvalid
            })
            if self.masterTaskId == UIBackgroundTaskInvalid {
                self.masterTaskId = bgTaskId
                print("started master task \(self.masterTaskId)")
            } else {
                //add this id to our list
                print("started background task \(bgTaskId)")
                self.bgTaskIdList.append(bgTaskId)
                self.endBackgroundTasks()
            }
        }
        return bgTaskId
    }
    
    func endBackgroundTasks() {
        self.drainBackgroundTaskList(all: false)
    }
    
    func endAllBackgroundTasks() {
        self.drainBackgroundTaskList(all: true)
    }
    
    func drainBackgroundTaskList(all: Bool) {
        
        let application = UIApplication.shared
        
        if application.responds(to: #selector(self.endBackgroundTasks)) {
            
            for backgroundTaskId in bgTaskIdList {
                print("Ending bg task with id \(backgroundTaskId)")
                application.endBackgroundTask(backgroundTaskId)
                self.bgTaskIdList.remove(at: 0)
            }
            
            if self.bgTaskIdList.count > 0 {
                print("Kept bg task id \(self.bgTaskIdList[0])")
            }
            
            if all {
                print("No more bg tasks running")
                application.endBackgroundTask(self.masterTaskId)
                self.masterTaskId = UIBackgroundTaskInvalid
            } else {
                print("Kept master bg task id \(self.masterTaskId)")
            }
        }
    }
    
    
    
}
