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

class SearchTabViewController: UITableViewController, UISearchResultsUpdating, Themeable, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    
    let manager = CLLocationManager()
    
    // Currently only searching through jobs and not events
    var unfilteredJobs = [Job]()
    var filteredJobs: [Job]?
    var chosen: Int?
    
    
    // Search controller responsible for doing real-time text search
    let searchController = MySearchController(searchResultsController: nil)
    
    // Create unfiltered job list from Job CoreData
    override func viewDidLoad() {
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
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search for Jobs"
        navigationItem.titleView = searchController.searchBar
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveJobs()
        filteredJobs = unfilteredJobs
        table.reloadData()
        searchController.isActive = true
    }
    
    // Basic Table Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let returnedResults = filteredJobs else {
            return 0
        }
        
        return returnedResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableCell
    
        // Fill cells with jobs from filteredJobs
        if let returnedResults = filteredJobs {
            let result: Job = returnedResults[indexPath.row]
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
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // Real-time update search results per letter typed
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredJobs = unfilteredJobs.filter {
                job in return (job.jobTitle.lowercased().contains(searchText.lowercased()))
            }
        } else {
            filteredJobs = unfilteredJobs
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        if((table.cellForRow(at: indexPath) as! SearchTableCell).typeResult == "job") {
            self.performSegue(withIdentifier: "jobSearchResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "jobSearchResult") {
            let j:Job = filteredJobs![chosen!]
            let jobVC:JobViewController = segue.destination as! JobViewController
            jobVC.job = j
            jobVC.jobID = j.jobId
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
                self.unfilteredJobs.removeAll()
                
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
                    // Placeholder image
                    let placeholderImage = UIImage(named: "meeting")
                    job.image = placeholderImage
                    SDWebImageManager.shared().imageDownloader?.downloadImage(with:URL(string: job.imageAsString), options: SDWebImageDownloaderOptions.useNSURLCache, progress: nil, completed: { (image, error, cacheType, url) in
                        if image != nil {
                            job.image = image
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
                    
                    self.unfilteredJobs.append(job)
                    self.table.reloadData()
                    
                }
            }
        })
    }
    

    
    // Retrieve Events from CoreData
    // @TODO: Put this in a Util class.
    func retrieveEvents() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"EventEntity")
        var fetchedResults:[NSManagedObject]? = nil
        
        // Examples of filtering using predicates
        // let predicate = NSPredicate(format: "age = 35")
        // let predicate = NSPredicate(format: "name CONTAINS[c] 'ake'")
        // request.predicate = predicate
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults)!
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
