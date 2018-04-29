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
import NVActivityIndicatorView

class CommunityTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, Themeable {
    
    let manager = CLLocationManager()
    
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var table: UITableView!
    
    var loadingView: UIView!
    var activityIndicatorView: NVActivityIndicatorView!
    var errorLBL: UILabel!
    
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
        table.isHidden = true
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(loadingView)
        let frame = CGRect(x: screenWidth*0.5 - 30, y: screenHeight*0.5 - 30, width: 60, height: 60)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.circleStrokeSpin.rawValue))
        activityIndicatorView.color = UIColor(hex:"2b3445")
        loadingView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        retrieveEvents()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if (self.events.count == 0) {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                var frame = CGRect(x: self.loadingView.bounds.size.width*0.5 - 90, y: self.loadingView.bounds.size.height*0.5 - 175, width: 180, height: 350)
                let errorView = UIView(frame: frame)
                let size = CGSize(width: 180, height: 350)
                let errorGraphic = UIImageView(image: UIImage(named: "nojobs")?.scaleImageToSize(newSize: size))
                errorView.addSubview(errorGraphic)
                frame = CGRect(x: self.loadingView.bounds.size.width*0.5 - 90, y: self.loadingView.bounds.size.height*0.5 + 180, width: 180, height: 50)
                self.errorLBL = UILabel(frame: frame)
                self.errorLBL.lineBreakMode = .byWordWrapping
                self.errorLBL.numberOfLines = 0
                self.errorLBL.textAlignment = .center
                self.errorLBL.text = "There are currently no events in this area :("
                self.errorLBL.font = UIFont(name: "Gidole-Regular", size: 20)
                self.errorLBL.textColor = UIColor(hex:"2b3445")
                self.loadingView.addSubview(errorView)
                self.loadingView.addSubview(self.errorLBL)
            }
        }
    }
    
    // ** START TABLE FUNCTIONS ** \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if(!table.visibleCells.isEmpty) {
            activityIndicatorView.stopAnimating()
            loadingView.isHidden = true
            table.isHidden = false
        }
        
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
        cell.eventImg.layer.cornerRadius = 6.0
        cell.eventImg.clipsToBounds = true
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
            let eventID = (table.indexPathForSelectedRow?.row)!
            let eventSelected = events[eventID]
            eventVC.event = eventSelected
            eventVC.eventID = eventSelected.eventId
        }
    }
    
    // DATABASE RETRIEVAL
    func retrieveEvents() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
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
                    
                    if (event.distance <= UserDefaults.standard.value(forKey:"max_radius") as! Double)
                    {
                        self.events.append(event)
                        self.events = self.events.sorted(by: { $0.distance < $1.distance })
                    }
                
                    self.table.reloadData()
                    
                }
            }
        })
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyTabBarTintColor(tabBar: self.tabBarController!)
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyTableViewBackgroundColor(tableView: [table])
        for cell in table.visibleCells {
            theme.applyBodyTextStyle(labels: [ ((cell as! EventTableViewCell).eventDescriptionLbl!) ])
            theme.applyHeadlineStyle(labels: [ ((cell as! EventTableViewCell).eventTitleLbl!) ])
        }

    }
}
