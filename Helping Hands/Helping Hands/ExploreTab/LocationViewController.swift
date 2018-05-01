//
//  LocationViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/30/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI
import Contacts

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol AddressDelegate
{
    func sendAddress(address:String, latLong:(Double, Double))
}

class LocationViewController : UIViewController, CLLocationManagerDelegate, HandleMapSearch, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var delegate: AddressDelegate?
    var address:String?
    var latLong:(Double, Double)?
    var lastLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Search results table created
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // Search bar embedded into nav bar
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont(name: "Gidole-Regular", size: 18)!
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        // Results view attributes
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        // More prep work
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enableBasicLocationServices()
    }
    
    // asynchronously determines whether or not changes to location settings have been made and responds
    // by asking user to turn them back on for the app.
    func enableBasicLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            enableMyWhenInUseFeatures()
            break
        }
    }
    
    // Prevents Location Features from being called, asks user to enable them
    func disableMyLocationBasedFeatures() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let SWRController: EnableLocationViewController = storyboard.instantiateViewController(withIdentifier: "allowLocationPls") as! EnableLocationViewController
        self.present(SWRController, animated: true, completion: nil)
    }
    
    // Enables Location Features
    func enableMyWhenInUseFeatures() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.startUpdatingLocation()
        locationManager.requestLocation()
    }
    
    // asynchronously determines whether or not changes to location settings have been made and responds
    // by asking user to turn them back on for the app.
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        // Display page asking to turn back on settings to use the app.
        case .restricted, .denied:
            disableMyLocationBasedFeatures()
            break
            
        // If authorized, load in jobs
        case .authorizedWhenInUse, .authorizedAlways:
            enableMyWhenInUseFeatures()
            break
            
        // Not happening
        case .notDetermined:
            break
        }
    }
    
    // Used to update view on MKMap. Starts off at current location, but will move to the last location it's
    // centered on
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(lastLocation == nil) {
            lastLocation = locations.first
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: lastLocation!.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
        }
        else {
            lastLocation = locations.last
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("error:: (error)")
    }
    
    // If the user selects a location from the search result, zoom in on a pin in the MKMapView
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        // Subtitle for annotation becomes address using two methods depending on iOS version
        if #available(iOS 11.0, *) {
            annotation.subtitle = CNPostalAddressFormatter.string(from: placemark.postalAddress!, style: .mailingAddress)
        } else {
            annotation.subtitle = ABCreateStringWithAddressDictionary(placemark.addressDictionary!, false)
        }
        
        // Address will be the string value passed and stored into models
        address = annotation.subtitle
        // Geographic coordinates will also be passed and stored into models
        // for distance calculations
        latLong = (placemark.coordinate.latitude, placemark.coordinate.longitude)
        
        // Add annotation
        mapView.addAnnotation(annotation)
        
        // Center on new pin
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    // Draws the pin that will be zoomed in on
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 100, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(x:0, y:0), size: smallSquare))
        button.backgroundColor = UIColor.blue
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.setTitle("Confirm", for: UIControlState.normal)
        pinView?.rightCalloutAccessoryView = button
        button.addTarget(self, action:#selector(action(sender:)), for: .touchUpInside)
        return pinView
    }
    
    @objc fileprivate func action(sender: UIButton) {
        self.delegate?.sendAddress(address: self.address!, latLong: self.latLong!)
        self.navigationController?.popViewController(animated: true)
    }
}
