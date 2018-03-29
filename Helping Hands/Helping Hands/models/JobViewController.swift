//
//  JobViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseStorageUI
import FirebaseAuth
import FirebaseDatabase
import UIImageColors

class JobViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var imgGradientView: UIView!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var jobPrice: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobDistance: UILabel!
    @IBOutlet weak var jobDescription: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navButton: UIBarButtonItem!
    
    var masterView:HomeTabViewController?
    var jobID:String?
    var clearCore: Bool = false
    var job:Job?
    var inquiries = [User]()
    var chosen:Int?
    var j:Job!
    
    override func viewDidAppear(_ animated: Bool) {
        if(jobID == "0") {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        table.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(jobID == "0") {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        table.dataSource = self
        table.delegate = self
        
        j = job
        
        let url = URL(string: j.imageAsString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                // Placeholder image
                self.jobPhoto.image = UIImage(named:"meeting")
                print("error downloading picture")
                return
            }
            self.jobPhoto.image = UIImage(data: data!)
        }
        
        jobTitle.text = j.jobTitle
        let ftmPayment = "$" + (j.payment.truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        jobPrice.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        jobDate.text = j.jobDateString
        jobDistance.text = String(j.distance) + " mi"
        jobLocation.text = j.address
        jobDescription.text = j.jobDescription
    }
    
    override func viewDidLayoutSubviews() {
        let colors = jobPhoto.image?.getColors()
        
        let color1 = colors?.background
        let color2 = colors?.primary
        
        self.imgGradientView.setGradientBackground(colorOne: color1!, colorTwo: color2!)
        jobPhoto.layer.shadowColor = UIColor.black.cgColor
        jobPhoto.layer.shadowOpacity = 0.6
        jobPhoto.layer.shadowOffset = CGSize.zero
        jobPhoto.layer.shadowRadius = 8
        jobPhoto.layer.shouldRasterize = true
    }
    
    // UPDATE WITH ALL FIELDS TAKEN FROM DATABASE
    override func viewWillAppear(_ animated: Bool) {
        retrieveJobs()
        
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        self.jobPhoto.sd_setImage(with: URL(string: j.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        jobTitle.text = j.jobTitle
        let ftmPayment = "$" + (j.payment.truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        jobPrice.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        jobDate.text = j.jobDateString
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
            let u:User = inquiries[chosen!]
            let userVC:UserViewController = segue.destination as! UserViewController
            userVC.user = u
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
    
    @IBAction func addUser(_ sender: Any) {
        if(jobID == "0")
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
    
    // FIREBASE RETRIEVAL
    func retrieveJobs() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let jobRef = databaseRef.child("jobs").child(jobID!)
        
        jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // retrieve jobs and append to job list after creation
            let jobObject = snapshot.value as! [String: AnyObject]
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
            job.jobId = snapshot.ref.key
    
            self.job = job
            self.table.reloadData()
        })
    }
    
}
