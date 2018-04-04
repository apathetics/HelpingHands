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
    func sendAddress(address:String)
}

class LocationViewController : UIViewController, CLLocationManagerDelegate, HandleMapSearch, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var delegate: AddressDelegate?
    var address:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("error:: (error)")
    }
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if #available(iOS 11.0, *) {
            annotation.subtitle = CNPostalAddressFormatter.string(from: placemark.postalAddress!, style: .mailingAddress)
        } else {
            annotation.subtitle = ABCreateStringWithAddressDictionary(placemark.addressDictionary!, false)
        }
        address = annotation.subtitle
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
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
        button.setTitle("Confirm Location", for: UIControlState.normal)
        pinView?.rightCalloutAccessoryView = button
        button.addTarget(self, action:#selector(action(sender:)), for: .touchUpInside)
        return pinView
    }
    
    @objc fileprivate func action(sender: UIButton) {
        self.delegate?.sendAddress(address: self.address!)
        self.navigationController?.popViewController(animated: true)
    }
}
