//
//  SignUpWithPhoneVC+Location.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CoreLocation

extension SignUpWithPhoneVC: CLLocationManagerDelegate {
    func updateLocation() {
        // For use in foreground

        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard shouldDefineLocation, locations.count > 0 else {return}
        let location = locations[0]
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, _) in
            guard let placemarks = placemarks, placemarks.count > 0 else {return}
            let placemark = placemarks[0]
            guard let countryCode = placemark.isoCountryCode,
                let country = SelectCountryViewModel.getCountriesList().first(where: {$0.countryCode == countryCode})
            else { return }

            if country.available {
                self.viewModel.selectedCountry.accept(country)
            }
        }
    }
}
