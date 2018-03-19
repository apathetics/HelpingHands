//
//  JobViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class JobViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var job:NSManagedObject?
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var jobInquiries: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        return cell
    }
    
    var masterView:HomeTabViewController?
    
    var clearCore: Bool = false
    
    var jobToAdd:Job?
    var jobs = [NSManagedObject]()
    
    @IBOutlet weak var table: UITableView!
    /*
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:JobTableViewCell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobTableViewCell
        
        let row = indexPath.row
        let j:NSManagedObject = jobs[row]
        
        cell.jobTitleLbl.text = j.value(forKey: "jobTitle") as? String
        cell.jobDescriptionLbl.text = j.value(forKey: "jobDescription") as? String
        cell.distanceLbl.text = String(j.value(forKey: "jobDistance") as! Double) + " mi"
        let ftmPayment = "$" + ((j.value(forKey: "jobPayment") as! Double).truncatingRemainder(dividingBy: 1) == 0 ? String(j.value(forKey: "jobPayment") as! Int64) : String(j.value(forKey: "jobPayment") as! Double))
        print("PAYMENT IS:", ftmPayment)
        cell.paymentLbl.text = j.value(forKey: "jobIsHourlyPaid") as! Bool == true ? ftmPayment + "/hr" : ftmPayment
        cell.jobImg.image = UIImage(data: j.value(forKey: "jobImage") as! Data)
        
        return cell
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobPhoto.image = UIImage(data: job?.value(forKey: "jobImage") as! Data)
        jobTitle.text = job?.value(forKey: "jobTitle") as? String
        jobDescription.text = job?.value(forKey: "jobDescription") as? String
        // Do any additional setup after loading the view, typically from a nib.
        /*
        if clearCore {
            clearCoreJob()
        }*/
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        jobs = [NSManagedObject]()
        
        for job in retrieveJobs() {
            jobs.append(job)
        }
        
        //table.reloadData()
    }*/
/*
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
    
    func clearCoreJob() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "JobEntity")
        var fetchedResults:[NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                    print("\(result.value(forKey: "jobTitle")!) has been Deleted")
                }
            }
            try context.save()
            
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
    }
  */
}
