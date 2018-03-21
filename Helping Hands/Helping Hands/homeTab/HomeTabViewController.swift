//
//  HomeTabViewController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 2/28/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import FirebaseDatabase
import FirebaseStorageUI

class HomeTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    var jobs = [Job]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:JobTableViewCell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobTableViewCell
        
        let row = indexPath.row
        let j:Job = jobs[row]
        
        cell.jobTitleLbl.text = j.jobTitle
        cell.jobDescriptionLbl.text = j.jobDescription
        cell.distanceLbl.text = String(j.distance) + " mi"
        let ftmPayment = "$" + ((j.payment).truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        cell.paymentLbl.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        cell.jobImg.sd_setImage(with: URL(string: j.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        
        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Location pemissions
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addJobVC:AddJobViewController = segue.destination as! AddJobViewController
        addJobVC.masterView = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveJobs()
    }
    
    // POSSIBLE SOLUTION FOR URL TO DATA RETRIEVAL (not sure how @escaping works tbh)
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    // FIREBASE RETRIEVAL
    func retrieveJobs() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let jobsRef = databaseRef.child("jobs")
        
        jobsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                
                // clear job list before appending again
                self.jobs.removeAll()
                
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
                    job.imageAsString = jobObject["jobImageUrl"] as! String
                    
                    job.isHourlyPaid = jobObject["jobIsHourlyPaid"] as! Bool
                    job.numHelpers = jobObject["jobNumHelpers"] as! Int
                    job.payment = jobObject["jobPayment"] as! Double
                    job.jobTitle = jobObject["jobTitle"] as! String
                    
                        
                    self.jobs.append(job)
                    self.table.reloadData()
                    
                }
            }
        })
    }
}

