//
//  GeofenceService.swift
//  Runner
//
//  Created by Hashim Khan on 14/11/2024.
//


import Foundation
import CoreLocation
import Flutter
import BackgroundTasks

class GeofenceService : NSObject, CLLocationManagerDelegate{
    
    static let shared = GeofenceService()
    

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
    
    
    
    
    func startMonitoringGeofence(at location: CLLocationCoordinate2D,radius : Double = 100, fromLocationService : Bool = false){
        
        
        if(fromLocationService){
            let geofences = Array(locationManager.monitoredRegions)
            if(!geofences.isEmpty){
                return
            }
        }
              
        let region = CLCircularRegion(center: location, radius: radius, identifier: UUID().uuidString)
        region.notifyOnEntry = false
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
    
    
    func stopMonitoringGeofence(){
        for region in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: region)
        }
    }
    
  
    func manageGeofences(){
        let geofences = Array(locationManager.monitoredRegions)
        
        if geofences.count >= 10{
            for i in 0..<5 {
                if let regionToRemove = geofences[i] as? CLCircularRegion{
                    locationManager.stopMonitoring(for: regionToRemove)
                }
            }
        }
    }
    
    // MARK: - Geofence Exit Callback
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        manageGeofences()
        
        
        guard let currentLocation = manager.location else {
            return
        }
        
        let locationAge = abs(currentLocation.timestamp.timeIntervalSinceNow)
        
        if(locationAge > 30 || currentLocation.horizontalAccuracy < 0){
            return
        }
        
        
        do{
            FirebaseLocationLogUpdater().updateLocationInFirebase( location: CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude),fromGeofence: true)
        }
        catch(_){
            
        }
        startMonitoringGeofence(at: currentLocation.coordinate)
    }
    
    
    

    
}
