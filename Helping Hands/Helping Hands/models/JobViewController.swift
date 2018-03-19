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
    
    var masterView:HomeTabViewController?
    var clearCore: Bool = false
    var job:NSManagedObject?
    
    var userToAdd:User?
    var inquiries = [User]()
    var chosen:Int?
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var jobPrice: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobDistance: UILabel!
    @IBOutlet weak var jobDescription: UITextView!
    
    @IBOutlet weak var table: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inquiries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("indextPath")
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        let row = indexPath.row
        let u:User = inquiries[row]
        
        
        cell.userImg.image = u.userPhoto
        cell.userName.text = u.userFirstName + " " + u.userLastName
        /*
        cell.distanceLbl.text = String(j.value(forKey: "jobDistance") as! Double) + " mi"
        let ftmPayment = "$" + ((j.value(forKey: "jobPayment") as! Double).truncatingRemainder(dividingBy: 1) == 0 ? String(j.value(forKey: "jobPayment") as! Int64) : String(j.value(forKey: "jobPayment") as! Double))
        print("PAYMENT IS:", ftmPayment)
        cell.paymentLbl.text = j.value(forKey: "jobIsHourlyPaid") as! Bool == true ? ftmPayment + "/hr" : ftmPayment
        cell.jobImg.image = UIImage(data: j.value(forKey: "jobImage") as! Data)
         */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        self.performSegue(withIdentifier: "showInquiry", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showInquiry")
        {
            let j:User = inquiries[chosen!]
            let userVC:UserViewController = segue.destination as! UserViewController
            userVC.masterView = self
            userVC.user = j
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        jobPhoto.image = UIImage(data: job?.value(forKey: "jobImage") as! Data)
        jobTitle.text = job?.value(forKey: "jobTitle") as? String
        let ftmPayment = "$" + ((job?.value(forKey: "jobPayment") as! Double).truncatingRemainder(dividingBy: 1) == 0 ? String(job?.value(forKey: "jobPayment") as! Int64) : String(job?.value(forKey: "jobPayment") as! Double))
        jobPrice.text = job?.value(forKey: "jobIsHourlyPaid") as! Bool == true ? ftmPayment + "/hr" : ftmPayment
        jobDate.text = getDate(date: job?.value(forKey:"jobDate") as! NSDate)
        jobDistance.text = String(job?.value(forKey: "jobDistance") as! Double) + " mi"
        
        // To be done when location is more than an illusion
        //if(job?.value(forKey: "currentLocation") as! Bool) {
        jobLocation.text = "curLocation"
        //}
        /*
        else {
            jobLocation.text = job?.value(forKey: "jobLocation") as? String
        }
        */
        
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
    
    func getDate(date: NSDate) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MM/dd/yyyy"
        return dateFormate.string(from: date as Date)
    }
    func getTime(date: NSDate) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "HH:mm"
        return dateFormate.string(from: date as Date)
    }
    
    @IBAction func addUser(_ sender: Any) {
        let inquiry:User = User()
        inquiry.userFirstName = "Emiliano"
        inquiry.userLastName = "Zapata"
        inquiry.userPhoto = UIImage()
        inquiry.userBio = "I like being a revolutionary, it's fun."
        inquiry.userEmail = "porfirioHater1912@mexico.com"
        inquiry.userLocationRadius = 0.0
        inquiry.userNumJobsPosted = 1
        inquiry.userNumJobsPending = 2
        inquiry.userJobsCompleted = 4
        
        inquiries.append(inquiry)
        self.table.reloadData()
    }

/*
    func retrieveinquiries() -> [NSManagedObject] {
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
