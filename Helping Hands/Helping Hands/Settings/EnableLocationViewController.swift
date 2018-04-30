//
//  EnableLocationViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 4/29/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreLocation

class EnableLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Enables Location Features
    func dismissLocationWarning() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // asynchronously determines whether or not changes to location settings have been made and responds
    // by asking user to turn them back on for the app.
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        // Display page asking to turn back on settings to use the app.
        case .restricted, .denied:
            break
            
        // If authorized, load in jobs
        case .authorizedWhenInUse, .authorizedAlways:
            dismissLocationWarning()
            break
            
        // Not happening
        case .notDetermined:
            break
        }
    }
    
}
