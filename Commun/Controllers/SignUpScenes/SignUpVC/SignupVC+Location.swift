//
//  SignupVC+Location.swift
//  Commun
//
//  Created by Chung Tran on 7/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CoreLocation

extension SignUpVC: CLLocationManagerDelegate {
    func updateLocation() {
        // For use in foreground
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard locations.count > 0 else {return}
        let location = locations[0]
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemarks = placemarks, placemarks.count > 0 else {return}
            let placemark = placemarks[0]
            guard let country = placemark.country else {return}
            print(country)
        }
    }
}
