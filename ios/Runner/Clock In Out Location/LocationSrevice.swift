//
//  LocationSrevice.swift
//  Runner
//
//  Created by TMS on 11/12/2023.
//

import Foundation
import CoreLocation
import Flutter
import BackgroundTasks

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    static var isTrackingOn : Bool = false;

    private var locationManager: CLLocationManager

    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.showsBackgroundLocationIndicator = true
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = kCLDistanceFilterNone
    }

    // MARK: - Public Methods

    func startLocationService()  {
//        var hasAlwaysPermission  = false;    
        LocationService.shared.hasLocationAlwaysPermission{
            hasPermission in
            if(hasPermission){
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.pausesLocationUpdatesAutomatically = false
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.locationManager.distanceFilter = kCLDistanceFilterNone
                self.locationManager.showsBackgroundLocationIndicator = true
                self.locationManager.startUpdatingLocation()
//                self.scheduleLocationRefresh()
            }
            else{
                self.requestForAlwaysLocationPermission()
            }
        }
        LocationService.isTrackingOn = true;
    }


    func setupLocationServiceOnAppRelaunch()  {
        LocationService.shared.hasLocationAlwaysPermission{
            hasPermission in
            if(hasPermission){
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.pausesLocationUpdatesAutomatically = false
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.locationManager.distanceFilter = kCLDistanceFilterNone
                self.locationManager.showsBackgroundLocationIndicator = true
                self.locationManager.startMonitoringSignificantLocationChanges()
            }
            else{
                self.requestForAlwaysLocationPermission()
            }
        }
        LocationService.isTrackingOn = true;
    }

    func stopLocationService() {
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.locationManager.stopUpdatingLocation()
        LocationService.isTrackingOn = false;
        ClockInOutSession.clearSession()
        GeofenceService.shared.stopMonitoringGeofence()
    }

    func appEnterBackground(){
        if(LocationService.isTrackingOn){
            locationManager.stopUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func appEnterForeground(){
        if(LocationService.isTrackingOn){
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
    }

    func isServiceRunning() -> Bool {
        return locationManager.allowsBackgroundLocationUpdates
    }

    func hasLocationAlwaysPermission(completion : @escaping (Bool) -> Void)  {
        DispatchQueue.global().async {
            let result = CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() == .authorizedAlways
            
            //
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func requestForAlwaysLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         // Handle new location data here
        if let location = locations.last {
          let latitude = location.coordinate.latitude
          let longitude = location.coordinate.longitude
            
            
            let locationAge = abs(location.timestamp.timeIntervalSinceNow)
            
            if(locationAge > 30 || location.horizontalAccuracy < 0){
                return
            }
            
            
          let locationData: [String: Any] = ["latitude": latitude, "longitude": longitude, "speed" : location.speed , "heading" : location.course]
            
            GeofenceService.shared.startMonitoringGeofence(at: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),fromLocationService: true)

            do{
                LocationChannel.channel?.invokeMethod("onLocationUpdate", arguments: locationData)
            }
            catch(_){
                
            }
             do{
                 FirebaseLocationLogUpdater().updateLocationInFirebase( location: location)
             }
             catch(_){
                
             }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle authorization status changes, e.g., request permission if needed
        switch status {
        case .authorizedAlways:
            // The user has granted "Always" location access
            // Start or continue location updates as needed
            break
        case .authorizedWhenInUse:
            // The user has granted "When In Use" location access
            // Start or continue location updates as needed
            break
        case .denied, .restricted:
            // The user has denied or restricted location access
            // Handle this situation, prompt the user to change settings, etc.
            break
        case .notDetermined:
            // Location permission has not been requested yet
            // You can request permission here
            locationManager.requestAlwaysAuthorization()
            break
        default:
            break
        }
    }

//    func sendLocationToDart(){
//        
//            if(self.locationManager.location != nil){
//                let latitude = self.locationManager.location!.coordinate.latitude
//                let longitude = self.locationManager.location!.coordinate.longitude
//                let locationData: [String: Any] = ["latitude": latitude, "longitude": longitude, "speed" : self.locationManager.location!.speed , "heading" : locationManager.location!.course]
//                LocationChannel.channel?.invokeMethod("onLocationUpdate", arguments: locationData)
//                if(LocationChannel.channel == nil){
//                    showNotification(title: "Channel methods", body: "Got null channel while updating location.")
//                }
//            }
//        else{
//            showNotification(title: "Location update", body: "Got null location in update location call.")
//        }
//        
//        print("location updated by background fetch");
//    }


//    func scheduleLocationRefresh() {
//        if #available(iOS 13.0, *) {
//            let request = BGAppRefreshTaskRequest(identifier: "com.transportsystemgroup.tsadmin")
//            // Fetch no earlier than 10 sec from now.
//            request.earliestBeginDate = Date(timeIntervalSinceNow: 10)
//            
//            do {
//                try BGTaskScheduler.shared.submit(request)
//                showNotification(title: "Background Registeration", body: "Background service request submitted.")
//            } catch {
//                showNotification(title: "Background Registeration", body: "Unable to register background service.")
//                print("Could not schedule app refresh: \(error)")
//            }
//        }
//        
//    }

//    func stopScheduleLocationRefresh() {
//        if #available(iOS 13.0, *) {
//             BGTaskScheduler.shared.cancelAllTaskRequests()
//        }
//    }
    
//    func showNotification(title: String, body: String) {
//            let content = UNMutableNotificationContent()
//            content.title = title
//            content.body = body
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//            let request = UNNotificationRequest(identifier: "NotificationIdentifier", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request) { (error) in
//                if let error = error {
//                    print("Error presenting notification: \(error.localizedDescription)")
//                }
//            }
//        }
    
    
}
