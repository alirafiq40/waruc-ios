//
//  Location.swift
//  ios-app
//
//  Created by Babbs, Dylan on 6/3/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    
    override init() {
        super.init()
    }
    
    static let sharedInstance = Location()
    
    var washington = true
    
    var locationManager = CLLocationManager()
    
    //Tracking setup
    
    var realTimeDistance = CLLocation()
    var currentLoc = CLLocation()
    var tripDistance = Double()
    var tripStartTime = Date()
    var initialLocation = false
    
    var tracking = false
    
    var locationSpeedAggregator:[Double] = []
    var graphSpeeds:[Double] = []
    var currentTs = 0
    
    var currentMph = 0.0
    
    let mphUpdateNotification = Notification.Name("mphUpdateNotification")
    let graphUpdateNotification = Notification.Name("graphUpdateNotification")
    
    func startTracking() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 25 //meter interval for location updating
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        initialLocation = true
        
        
        self.tripStartTime = Date()
        print("*** 📍GPS: Successfully connected!💦 ***")
        let values = ["connection": "GPS"]
        NotificationCenter.default.post(name: Notification.Name("LocationConnectionUpdateNotificatonIdentifier"), object: values)
    }
    
    func stopTracking() {
        tracking = false
        // Convert meters to miles w/ tripDistance * 0.000621371
        //if washington {
        print("Wrote trip with vehicle vin: \(DB.sharedInstance.currVehicleInfo!["vin"]!), distance: \(tripDistance * 0.000621371)")
        DB.sharedInstance.writeTrip(miles: tripDistance * 0.000621371, vin: DB.sharedInstance.currVehicleInfo!["vin"]!)
        //}
        tripDistance = 0.0
        
        NotificationCenter.default.post(name: Notification.Name("LocationConnectionUpdateNotificatonIdentifier"), object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // App may no longer be authorized to obtain location
        //information. Check status here and respond accordingly
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle errors here 
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        let currentLatitude:Double = location.coordinate.latitude
        let currentLongitude:Double = location.coordinate.longitude
        
        // Reverse geocoder to update city label
        let geocoder = GMSGeocoder()
        var result = "result"
        let temp = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        
        geocoder.reverseGeocodeCoordinate(temp) {
            response , error in
            if let address = response?.firstResult() {
                if address.locality == nil || address.administrativeArea == nil {
                    result = "Unknown, USA"
                } else {
                    if address.administrativeArea! != "Washington" {
                        _ = "\(address.locality!), \(address.administrativeArea!)"
                        result = "Outside of WA"
                        self.washington = false
                    } else {
                        result = "\(address.locality!)"
                    }
                    print("CITY: \(result)")
                    if result.characters.count < 13 {
                        result += ", WA"
                    } else if result.characters.count > 15 {
                        let index = result.index(result.startIndex, offsetBy: 13)
                        result = result.substring(to: index)
                        result += "..."
                    }
                    //result = "123456789012" //15
                }
            }
            let resultDict:[String: String] = ["text": result]
            NotificationCenter.default.post(name: Notification.Name("cityHeaderNotification"), object: nil, userInfo: resultDict)
            let hideDict:[String: Bool] = ["status": false]
            NotificationCenter.default.post(name: Notification.Name("locationIconNotification"), object: nil, userInfo: hideDict)
        }
        
        //GPS tracking 
        if tracking {
            if initialLocation {
                realTimeDistance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                currentLoc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                initialLocation = false
            } else {
                currentLoc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                //print("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                let meters = distanceCalc(coordinateOne: realTimeDistance, coordinateTwo: currentLoc)
                tripDistance += meters
                
                let date = Date()
                let ts = Int(date.timeIntervalSince1970.rounded())
                if ts - currentTs > 5 {
                    let meters_per_second = locationSpeedAggregator.reduce(0.0, +) / 5.0
                    
                    let mph = meters_per_second * 2.23694
                    NotificationCenter.default.post(name: mphUpdateNotification, object: ["speed": mph])
                    
                    if graphSpeeds.count >= 10 {
                        graphSpeeds.remove(at: 0)
                    }
                    
                    graphSpeeds.append(meters_per_second)
                    NotificationCenter.default.post(name: graphUpdateNotification, object: nil)
                    locationSpeedAggregator = []
                    currentTs = ts
                } else {
                    locationSpeedAggregator.append(meters)
                }
            }
            realTimeDistance = currentLoc
        }
    }
    
    func distanceCalc(coordinateOne: CLLocation, coordinateTwo: CLLocation) -> Double {
        /* 
        From Apple:
        This method measures the distance between the two locations by tracing a line 
        between them that follows the curvature of the Earth. The resulting arc is a 
        smooth curve and does not take into account specific altitude changes between 
        the two locations.
        */
         
        var distance : Double = 0.0
        distance = coordinateOne.distance(from: coordinateTwo)
        return distance
    }
}
