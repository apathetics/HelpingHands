//
//  SearchTabViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/1/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase

class SearchTabViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var table: UITableView!
    
    // Currently only searching through jobs and not events
    var unfilteredJobs = [Job]()
    var filteredJobs: [Job]?
    
    // Search controller responsible for doing real-time text search
    let searchController = UISearchController(searchResultsController: nil)
    
    // Create unfiltered job list from Job CoreData
    override func viewDidLoad() {
        
        // Search bar settings
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveJobs()
        filteredJobs = unfilteredJobs
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
            cell.jobTitleLabel.text = result.jobTitle
            cell.picture.image = result.image
            cell.distanceLabel.text = String(result.distance)
            cell.descriptionLabel.text = result.jobDescription
        }
        
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
    
    // FIREBASE RETRIEVAL
    func retrieveJobs() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let jobsRef = databaseRef.child("jobs")
        
        jobsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                
                // clear job list before appending again
                self.unfilteredJobs.removeAll()
                
                // for each snapshot (entity present under jobs child)
                for jobSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    let jobObject = jobSnapshot.value as! [String: AnyObject]
                    let job = Job()
                    
                    job.address = jobObject["jobAddress"] as! String
                    job.currentLocation = jobObject["jobCurrentLocation"] as! Bool
                    job.jobDateString = jobObject["jobDate"] as! String
                    job.jobDescription = jobObject["jobDescription"] as! String
                    job.distance = jobObject["jobDistance"] as! Double
                    
                    // TODO: Image from URL?
                    job.image = UIImage(named: "meeting")
                    
                    job.isHourlyPaid = jobObject["jobIsHourlyPaid"] as! Bool
                    job.numHelpers = jobObject["jobNumHelpers"] as! Int
                    job.payment = jobObject["jobPayment"] as! Double
                    job.jobTitle = jobObject["jobTitle"] as! String
                    
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
}
