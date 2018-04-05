//
//  CommunityTabViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/1/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import FirebaseDatabase
import FirebaseStorageUI

class CommunityTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, Themeable {
    
    let manager = CLLocationManager()
    
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var table: UITableView!
    
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ThemeService.shared.addThemeable(themable: self)
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Location permissions
        manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            manager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveEvents()
    }
    
    // ** START TABLE FUNCTIONS ** \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        let row = indexPath.row
        let e:Event = events[row]
        
        cell.eventTitleLbl.text = e.eventTitle
        cell.eventDescriptionLbl.text = e.eventDescription
        cell.distanceLbl.text = String(format: "%.2f", e.distance) + " mi"
        cell.helpersLbl.text = String(e.numHelpers) + " Helpers"
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        cell.eventImg.sd_setImage(with: URL(string: e.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        cell.backgroundColor = UIColor.clear
        return cell
    }
    // ** END TABLE FUCTIONS ** \\
    
    // PREPARE SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addEvent" {
            let addEventVC:AddEventViewController = segue.destination as! AddEventViewController
            addEventVC.masterView = self
        }
        else if segue.identifier == "showEvent" {
            let eventVC:EventViewController = segue.destination as! EventViewController
            eventVC.masterView = self
            let eventID = (table.indexPathForSelectedRow?.row)!
            let eventSelected = events[eventID]
            eventVC.e = eventSelected
            eventVC.eventID = eventSelected.eventId
        }
    }
    
    // DATABASE RETRIEVAL
    func retrieveEvents() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let eventsRef = databaseRef.child("events")
        
        eventsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are events
            if snapshot.childrenCount > 0 {
                
                // clear event list before appending again
                self.events.removeAll()
                
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
                    
                    let locationManager = CLLocationManager()
                    locationManager.delegate = self;
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                    let distance = (locationManager.location?.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude)) as! Double) * 0.00062137
                    event.distance = distance
                    
                    self.events.append(event)
                    self.table.reloadData()
                    
                }
            }
        })
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyTableViewBackgroundColor(tableView: [table])
        theme.applyTintColor_Font(navBar: self.navigationController!)
        for cell in table.visibleCells {
            theme.applyBodyTextStyle(labels: [ ((cell as! EventTableViewCell).eventDescriptionLbl!) ])
            theme.applyHeadlineStyle(labels: [ ((cell as! EventTableViewCell).eventTitleLbl!) ])
        }

    }
}
