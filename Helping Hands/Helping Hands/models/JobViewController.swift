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
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var jobPrice: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobDistance: UILabel!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navButton: UIBarButtonItem!
    
    var masterView:HomeTabViewController?
    var jobID:Int?
    var clearCore: Bool = false
    var job:NSManagedObject?
    var inquiries = [User]()
    var chosen:Int?
    var j:Job!
    
    override func viewDidAppear(_ animated: Bool) {
        if(jobID == 0) {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        table.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(jobID == 0) {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        table.dataSource = self
        table.delegate = self
        
        j = convertJob()
        jobPhoto.image = j.image
        jobTitle.text = j.jobTitle
        let ftmPayment = "$" + (j.payment.truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        jobPrice.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        jobDate.text = getDate(date:j.date! as NSDate)
        jobDistance.text = String(j.distance) + " mi"
        jobLocation.text = j.address
        jobDescription.text = j.jobDescription
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
        if clearCore {
            clearCoreJob()
        }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        jobPhoto.image = j.image
        jobTitle.text = j.jobTitle
        let ftmPayment = "$" + (j.payment.truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        jobPrice.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        jobDate.text = getDate(date:j.date! as NSDate)
        jobDistance.text = String(j.distance) + " mi"
        jobLocation.text = j.address
        jobDescription.text = j.jobDescription
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inquiries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        let row = indexPath.row
        let u:User = inquiries[row]
        
        
        cell.userImg.image = u.userPhoto
        cell.userName.text = u.userFirstName + " " + u.userLastName
        
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
            userVC.userIndexPath = chosen!
        }
        if(segue.identifier == "showJobEditor")
        {
            let editVC:EditJobViewController = segue.destination as! EditJobViewController
            editVC.masterView = self
            editVC.job = j
        }
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
        if(jobID == 0)
        {
            self.performSegue(withIdentifier: "showJobEditor", sender: self)
        }
        else {
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
            inquiry.userID = inquiries.count
            
            inquiries.append(inquiry)
            self.table.reloadData()
        }
    }
    
    func convertJob() -> Job {
        let j = Job()
        j.image = UIImage(data: job?.value(forKey: "jobImage") as! Data)
        j.jobTitle = job?.value(forKey: "jobTitle") as? String
        j.payment = job?.value(forKey: "jobPayment") as! Double
        j.date = job?.value(forKey:"jobDate") as! Date
        j.distance = job?.value(forKey: "jobDistance") as! Double
        j.jobDescription = job?.value(forKey: "jobDescription") as? String
        j.isHourlyPaid = job?.value(forKey: "jobIsHourlyPaid") as? Bool
        j.address = "curLocation"
        return j
    }
    
}