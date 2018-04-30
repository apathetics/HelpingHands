//
//  SearchTabViewController.swift
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

class SearchTabViewController: UITableViewController, UISearchResultsUpdating, Themeable, CLLocationManagerDelegate, SDWebImageManagerDelegate{
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    
    let manager = CLLocationManager()
    
    // Currently only searching through jobs and not events
    var unfilteredSearchResults = [SearchResult]()
    var filteredSearchResults: [SearchResult]?
    
    var chosen: Int?
    var searchBar: UISearchBar?
    
    
    // Search controller responsible for doing real-time text search
    let searchController = MySearchController(searchResultsController: nil)
    
    // Create unfiltered job list from Job CoreData
    override func viewDidLoad() {
        SDWebImageManager.shared().delegate = self
        SDWebImagePrefetcher.shared().manager.delegate = self
        self.definesPresentationContext = true
        self.hideKeyboardWhenTappedAround()
        ThemeService.shared.addThemeable(themable: self)
        // Search bar settings
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        
        tableView.rowHeight = 121
        super.viewDidLoad()
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont(name: "Gidole-Regular", size: 20)!
        """
        let attributes = [
            kCTForegroundColorAttributeName : UIColor.darkText,
            kCTFontAttributeName : UIFont(name: "Gidole-Regular", size: 20)!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: ([UISearchBar.self])).setTitleTextAttributes(attributes as [NSAttributedStringKey : Any], for: [])
        """
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search for Jobs or Events"
        navigationItem.titleView = searchController.searchBar
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.titleLabel!.font = UIFont(name: "Gidole-Regular", size: 20)
        }
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveJobs()
        retrieveEvents()
        filteredSearchResults = unfilteredSearchResults
        table.reloadData()
        searchController.isActive = true
    }
    
    // Basic Table Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let returnedResults = filteredSearchResults else {
            return 0
        }
        
        return returnedResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableCell
    
        // Fill cells with jobs from filteredSearchResults
        if let returnedResults = filteredSearchResults {
            let searchR: SearchResult = returnedResults[indexPath.row]
            if searchR.kind == "job" {
                let result = searchR.j!
                // Placeholder image
                let placeholderImage = UIImage(named: "meeting")
                // Load the image using SDWebImage
                cell.picture.image = result.image
                cell.picture.layer.cornerRadius = 6.0
                cell.picture.clipsToBounds = true
                cell.jobTitleLabel.text = result.jobTitle
                cell.picture.image = result.image
                cell.distanceLabel.text = String(format: "%.2f", result.distance) + " mi"
                cell.descriptionLabel.text = result.jobDescription
                cell.typeResult = "job"
            }
            else if searchR.kind == "event" {
                let result = searchR.e!
                // Placeholder image
                let placeholderImage = UIImage(named: "meeting")
                // Load the image using SDWebImage
                cell.picture.image = result.image
                cell.picture.layer.cornerRadius = 6.0
                cell.picture.clipsToBounds = true
                cell.jobTitleLabel.text = result.eventTitle
                cell.picture.image = result.image
                cell.distanceLabel.text = String(format: "%.2f", result.distance) + " mi"
                cell.descriptionLabel.text = result.eventDescription
                cell.typeResult = "event"
            }
        }
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // Real-time update search results per letter typed
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredSearchResults = unfilteredSearchResults.filter {
                result in return ((result.kind == "job" && result.j!.jobTitle.lowercased().contains(searchText.lowercased())) || (result.kind == "event" && result.e!.eventTitle.lowercased().contains(searchText.lowercased())))
                }
        }
        else {
            filteredSearchResults = unfilteredSearchResults
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        if((table.cellForRow(at: indexPath) as! SearchTableCell).typeResult == "job") {
            self.performSegue(withIdentifier: "jobSearchResult", sender: self)
        }
        else if((table.cellForRow(at: indexPath) as! SearchTableCell).typeResult == "event") {
            self.performSegue(withIdentifier: "eventSearchResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "jobSearchResult") {
            let j:Job = filteredSearchResults![chosen!].j!
            let jobVC:JobViewController = segue.destination as! JobViewController
            jobVC.job = j
            jobVC.jobID = j.jobId
        }
        
        if(segue.identifier == "eventSearchResult") {
            let e:Event = filteredSearchResults![chosen!].e!
            let eventVC:EventViewController = segue.destination as! EventViewController
            eventVC.event = e
            eventVC.eventID = e.eventId
        }
    }
    
    // FIREBASE RETRIEVAL
    func retrieveJobs() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
        let jobsRef = databaseRef.child("jobs")
        
        jobsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                
                // clear job list before appending again
                self.unfilteredSearchResults.removeAll()
                
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
                    
                    SDImageCache.shared().queryCacheOperation(forKey: job.imageAsString, done: { (image, data, type) in
                        if let image = image {
                            job.image = image
                        } else {
                            if let imgUrl = job.imageAsString {
                                SDWebImageManager.shared().loadImage(with: URL(string: imgUrl), options: [], progress: nil) { (image, data, error, type, done, url) in
                                    job.image = image
                                    SDImageCache.shared().store(image, forKey: job.imageAsString, completion: nil)
                                }
                            } else {
                                job.image = UIImage(named: "meeting")
                            }
                        }
                    })
                    
                    if(jobObject["latitude"] == nil)
                    {
                        job.latitude = 0
                        job.longitude = 0
                    }
                    else {
                        job.latitude = jobObject["latitude"] as! Double
                        job.longitude = jobObject["longitude"] as! Double
                    }
                    
                    let locationManager = self.manager
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                    let distance = (locationManager.location?.distance(from: CLLocation(latitude: job.latitude, longitude: job.longitude)) as! Double) * 0.00062137
                    job.distance = distance
                    
                    var j = SearchResult()
                    j.kind = "job"
                    j.j = job
                    
                    self.unfilteredSearchResults.append(j)

                    self.table.reloadData()
                    
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
                    
                    SDImageCache.shared().queryCacheOperation(forKey: event.imageAsString, done: { (image, data, type) in
                        if let image = image {
                            event.image = image
                        } else {
                            if let imgUrl = event.imageAsString {
                                SDWebImageManager.shared().loadImage(with: URL(string: imgUrl), options: [], progress: nil) { (image, data, error, type, done, url) in
                                    event.image = image
                                    SDImageCache.shared().store(image, forKey: event.imageAsString, completion: nil)
                                }
                            } else {
                                event.image = UIImage(named: "meeting")
                            }
                        }
                    })
                    
                    let locationManager = self.manager
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                    let distance = (locationManager.location?.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude)) as! Double) * 0.00062137
                    event.distance = distance
                    
                    var e = SearchResult()
                    e.kind = "event"
                    e.e = event
                    
                    self.unfilteredSearchResults.append(e)
                    self.table.reloadData()
                    
                }
            }
        })
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyTableViewBackgroundColor(tableView: [table])
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        for cell in table.visibleCells {
            theme.applyHeadlineStyle(labels: [(cell as! SearchTableCell).jobTitleLabel])
            theme.applyBodyTextStyle(labels: [(cell as! SearchTableCell).descriptionLabel])
        }
        theme.applySearchControllerStyle(searchBar: searchController)
    }
}

class MySearchController: UISearchController {
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissSearch()
    }
    
    func dismissSearch() {
        self.dismiss(animated: false, completion: nil)
    }
}
