//
//  ExploreTabViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/1/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorageUI

class ExploreTabViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, Themeable {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var chosenJob:Job?
    var chosenEvent:Event?
    var kindSegue:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        ThemeService.shared.addThemeable(themable: self)
        self.navigationController?.title = "Explore"
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        for _annotation in self.mapView.annotations {
            if let annotation = _annotation as? MKAnnotation
            {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        retrieveJobs()
        retrieveEvents()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for _annotation in self.mapView.annotations {
            if let annotation = _annotation as? MKAnnotation
            {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        retrieveJobs()
        retrieveEvents()
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        if let thisAnnotation = annotation as? JobAnnotation {
            pinView?.pinTintColor = UIColor.blue
            chosenJob = thisAnnotation.job!
            kindSegue = "showPinJob"
        }
        else if let thisAnnotation = annotation as? EventAnnotation {
            pinView?.pinTintColor = UIColor.orange
            chosenEvent = thisAnnotation.event!
            kindSegue = "showPinEvent"
        }
        
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 100, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(x:0, y:0), size: smallSquare))
        button.backgroundColor = UIColor.blue
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.setTitle("Checkout", for: UIControlState.normal)
        pinView?.rightCalloutAccessoryView = button
        button.addTarget(self, action:#selector(action(sender:)), for: .touchUpInside)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("chosen a pin!!!")
        if let annotation = view.annotation as? JobAnnotation {
            kindSegue = "showPinJob"
            chosenJob = annotation.job!
        }
        else if let annotation = view.annotation as? EventAnnotation {
            kindSegue = "showPinEvent"
            chosenEvent = annotation.event!
        }
    }
    
    @objc fileprivate func action(sender: UIButton) {
        self.performSegue(withIdentifier: kindSegue!, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showPinJob") {
            print(chosenJob!.jobTitle)
            let j:Job = chosenJob!
            let jobVC:JobViewController = segue.destination as! JobViewController
            jobVC.job = j
            jobVC.jobID = j.jobId
        }
        
        if(segue.identifier == "showPinEvent") {
            print(chosenEvent!.eventTitle)
            let e:Event = chosenEvent!
            let eventVC:EventViewController = segue.destination as! EventViewController
            eventVC.event = e
            eventVC.eventID = e.eventId
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyNavBarTintColor(navBar: self.navigationController!)
    }
    
    // FIREBASE RETRIEVAL
    func retrieveJobs() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
        let jobsRef = databaseRef.child("jobs")
        
        jobsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                
                // for each snapshot (entity present under jobs child)
                for jobSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    // retrieve jobs and append to job list after creation
                    let jobObject = jobSnapshot.value as! [String: AnyObject]
                    let job = Job()
                    
                    job.address = jobObject["jobAddress"] as! String
                    job.currentLocation = jobObject["jobCurrentLocation"] as! Bool
                    job.jobDateString = jobObject["jobDate"] as! String
                    job.jobDescription = jobObject["jobDescription"] as! String
                    job.distance = jobObject["jobDistance"] as! Double
                    job.imageAsString = jobObject["jobImageUrl"] as! String
                    job.isHourlyPaid = jobObject["jobIsHourlyPaid"] as! Bool
                    job.numHelpers = jobObject["jobNumHelpers"] as! Int
                    job.payment = jobObject["jobPayment"] as! Double
                    job.jobTitle = jobObject["jobTitle"] as! String
                    job.jobId = jobSnapshot.ref.key
                    if(jobObject["latitude"] == nil)
                    {
                        job.latitude = 0
                        job.longitude = 0
                    }
                    else {
                        job.latitude = jobObject["latitude"] as! Double
                        job.longitude = jobObject["longitude"] as! Double
                    }
                    
                    
                    let locationManager = CLLocationManager()
                    locationManager.delegate = self;
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                    let distance = (locationManager.location?.distance(from: CLLocation(latitude: job.latitude, longitude: job.longitude)) as! Double) * 0.00062137
                    job.distance = distance
                    
                    let annotation = JobAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: job.latitude, longitude: job.longitude)
                    annotation.title = job.jobTitle
                    annotation.job = job
                    annotation.subtitle = "Job paying $" + String(format: "%.2f", job.payment)
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }
    
    // DATABASE RETRIEVAL
    func retrieveEvents() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
        let eventsRef = databaseRef.child("events")
        
        eventsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are events
            if snapshot.childrenCount > 0 {
                
                // for each snapshot (entity present under events child)
                for eventSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    let eventObject = eventSnapshot.value as! [String: AnyObject]
                    let event = Event()
                    
                    event.address = eventObject["eventAddress"] as! String
                    event.currentLocation = eventObject["eventCurrentLocation"] as! Bool
                    event.eventDateString = eventObject["eventDate"] as! String
                    event.eventDescription = eventObject["eventDescription"] as! String
                    event.distance = eventObject["eventDistance"] as! Double
                    event.imageAsString = eventObject["eventImageUrl"] as! String
                    event.numHelpers = eventObject["eventNumHelpers"] as! Int
                    event.eventTitle = eventObject["eventTitle"] as! String
                    event.eventId = eventSnapshot.ref.key
                    if(eventObject["latitude"] == nil)
                    {
                        event.latitude = 0
                        event.longitude = 0
                    }
                    else {
                        event.latitude = eventObject["latitude"] as! Double
                        event.longitude = eventObject["longitude"] as! Double
                    }
                    
                    // Grab user's current location and calculate distance between event and user
                    let locationManager = CLLocationManager()
                    locationManager.delegate = self;
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                    let distance = (locationManager.location?.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude)) as Double?)! * 0.00062137
                    event.distance = distance
                    
                    let annotation = EventAnnotation()
                    annotation.event = event
                    annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
                    annotation.title = event.eventTitle
                    annotation.subtitle = "Event in need of " + String(event.numHelpers) + " helper"
                    if(event.numHelpers > 1) {
                        annotation.subtitle = annotation.subtitle! + "s"
                    }
                    
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }
}

class JobAnnotation: MKPointAnnotation {
    var job:Job?
}

class EventAnnotation: MKPointAnnotation {
    var event:Event?
}
