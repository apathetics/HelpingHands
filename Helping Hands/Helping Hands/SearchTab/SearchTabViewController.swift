//
//  SearchTabViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/1/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class SearchTabViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    
    // Currently only searching through jobs and not events
    var unfilteredJobs = [NSManagedObject]()
    var filteredJobs: [NSManagedObject]?
    
    // Search controller responsible for doing real-time text search
    let searchController = UISearchController(searchResultsController: nil)
    
    // Create unfiltered job list from Job CoreData
    override func viewDidLoad() {
        
        for job in retrieveJobs() {
            unfilteredJobs.append(job)
        }
        filteredJobs = unfilteredJobs
        
        // Search bar settings
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
            let result = returnedResults[indexPath.row]
            cell.jobTitleLabel.text = result.value(forKey: "jobTitle") as? String
            cell.picture.image = UIImage(data: result.value(forKey: "jobImage") as! Data)
            cell.distanceLabel.text = String(result.value(forKey: "jobDistance") as! Double)
            cell.descriptionLabel.text = result.value(forKey: "jobDescription") as? String
        }
        
        return cell
    }
    
    // Real-time update search results per letter typed
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredJobs = unfilteredJobs.filter {
                job in return ((job.value(forKey: "jobTitle") as? String)?.lowercased().contains(searchText.lowercased()))!
            }
        } else {
            filteredJobs = unfilteredJobs
        }
        tableView.reloadData()
    }
    
    // Retrieve Jobs from CoreData
    // @TODO: Put this in a Util class.
    func retrieveJobs() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"JobEntity")
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
