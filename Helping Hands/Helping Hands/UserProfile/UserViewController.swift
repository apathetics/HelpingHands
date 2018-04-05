//
//  UserViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorageUI

class UserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, Themeable {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userDistance: UILabel!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var jobBar: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-2-backup.firebaseio.com/")
    
    var imgChosen = false
    var user:User!
    var userIndexPath:Int?
    
//    var jobs = [Job]()
    
    var postedJobs = [Job]()
    var pendingJobs = [Job]()
    var completedJobs = [Job]()
    
    var chosen: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        
        table.delegate = self
        table.dataSource = self
        
        self.table.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveJobStatuses()
        retrieveUser()
        
        sleep(2)
        
        // check for user permissions to edit
        let userRef = databaseRef.child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.ref.key == self.userId {
//                print("SNAPSHOT KEY", snapshot.ref.key, self.userId)
                self.navigationItem.rightBarButtonItem?.title =  "Edit";
            }
        })
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        self.userPhoto.sd_setImage(with: URL(string: self.user.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })

        
        userName.text = (user.userFirstName)! + " " + (user?.userLastName)!
        userEmail.text = user.userEmail
        userDescription.text = user.userBio
        
        // Change the ones below
        userRating.text = String(describing: user.userRating!)
        userLocation.text = String(describing: user.userLocationRadius!)
        userDistance.text = String(describing: user.userDistance!)
        
        self.table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showEditUser")
        {
            let editorVC:EditUserViewController = segue.destination as! EditUserViewController
            editorVC.masterView = self
            print(user.userFirstName)
            editorVC.user = user
        }
        if(segue.identifier == "showJob") {
//            let j:Job = jobs[chosen!]
//            let jobVC:JobViewController = segue.destination as! JobViewController
//            jobVC.masterView = self
//            jobVC.job = j
//            jobVC.jobID = j.jobId
        }
    }
    
    @IBAction func segmentControlActionChanged(_ sender: Any) {
        print("I AM CHANGED")
        print("postedJobs", postedJobs, postedJobs.count)
        print("selected index", self.jobBar.selectedSegmentIndex)
        self.table.reloadData()
    }
    
    // ** START TABLE FUNCTIONS ** \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var selectedJobCount = 0
        
        switch(self.jobBar.selectedSegmentIndex) {
        case 0:
            print("HELLO I AM POSTEDJOBS:", postedJobs, postedJobs.count)
            selectedJobCount = postedJobs.count
            break
            
        case 1:
            selectedJobCount = pendingJobs.count
            break
            
        case 2:
            selectedJobCount = completedJobs.count
            break
            
        default:
            break
        }
        
        return selectedJobCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:JobTableViewCell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobTableViewCell
        let row = indexPath.row
        var j:Job?
        
        switch(jobBar.selectedSegmentIndex) {
        case 0:
            j = postedJobs[row]
            break
            
        case 1:
            j = pendingJobs[row]
            break
            
        case 2:
            j = completedJobs[row]
            break
            
        default:
            break
        }
        
        cell.jobTitleLbl.text = j!.jobTitle
        cell.jobDescriptionLbl.text = j!.jobDescription
        cell.distanceLbl.text = String(format: "%.2f", j!.distance) + " mi"
        let ftmPayment = "$" + ((j!.payment).truncatingRemainder(dividingBy: 1) == 0 ? String(j!.payment) : String(j!.payment))
        cell.paymentLbl.text = j!.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        cell.jobImg.sd_setImage(with: URL(string: j!.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch(jobBar.selectedSegmentIndex) {
        case 0:
            break
            
        case 1:
            break
            
        case 2:
            break
            
        default:
            break
        }
        
        chosen = (indexPath.row)
        print("CHOSEN IS: \(String(describing: chosen))")
//        self.performSegue(withIdentifier: "showJob", sender: self)
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onEditButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditUser", sender: self)
    }
    
    // FIREBASE RETRIEVAL
    func retrieveUser() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-2-backup.firebaseio.com/")
        let userRef = databaseRef.child("users").child(userId)
        
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // retrieve jobs and append to job list after creation
            let userObject = snapshot.value as! [String: AnyObject]
            let user = User()
            
            user.userFirstName = userObject["firstName"] as! String
            user.userLastName = userObject["lastName"] as! String
            user.userEmail = userObject["email"] as! String
            user.userJobsCompleted = userObject["jobsCompleted"] as! Int
            user.userNumJobsPosted = userObject["jobsPosted"] as! Int
            user.userMoneyEarned = userObject["moneyEarned"] as! Double
            user.userPhotoAsString = userObject["photoUrl"] as! String
            
            
            if(userObject["bio"] as? String == nil || userObject["bio"] as! String == "") {
                user.userBio = "Description..."
            }
            else {
                user.userBio = userObject["bio"] as! String
            }
            
            //TODO: SETTINGS NOT IN DATABASE YET
            user.userLocationRadius = 1
            user.userDistance = 1
            user.userRating = 5
            
            user.userID = self.userId
            
            self.user = user
        })
    }
    
    func retrieveJobStatuses() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-2-backup.firebaseio.com/")
        let currentUserRef = databaseRef.child("users").child(self.userId)
        
        var postedJobsId = [String]()
        var pendingJobsId = [String]()
        var completedJobsId = [String]()
        
        self.postedJobs.removeAll()
        self.pendingJobs.removeAll()
        self.completedJobs.removeAll()
        
        // JOBS POSTED ARRAY
        currentUserRef.child("jobsPostedArray").observe(FIRDataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                for jobsPostedSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    let jobsPostedObject = jobsPostedSnapshot.value as! [String: AnyObject]
                    
                    let jobId = jobsPostedObject["jobId"] as! String
                    postedJobsId.append(jobId)
                }
                print("I AM POSTED JOBS IDS: ", postedJobsId)
                
                for jobId in postedJobsId {
                    let jobRef = databaseRef.child("jobs").child(jobId)
                    
                    jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        
                        // retrieve jobs and append to job list after creation
                        let jobObject = snapshot.value as! [String: AnyObject]
                        let job = Job()
                        
                        job.address = jobObject["jobAddress"] as! String
                        job.latitude = jobObject["latitude"] as! Double
                        job.longitude = jobObject["longitude"] as! Double
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
                        
                        self.postedJobs.append(job)
                        self.table.reloadData()
                    })
                }
            }
        })
        
        //JOBS PENDING
        currentUserRef.child("jobsInquiredArray").observe(FIRDataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                for jobsPostedSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    let jobsPostedObject = jobsPostedSnapshot.value as! [String: AnyObject]
                    
                    let jobId = jobsPostedObject["jobId"] as! String
                    pendingJobsId.append(jobId)
                }
                print("I AM PENDING JOBS IDS: ", postedJobsId)
                
                for jobId in pendingJobsId {
                    let jobRef = databaseRef.child("jobs").child(jobId)
                    
                    jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        
                        // retrieve jobs and append to job list after creation
                        let jobObject = snapshot.value as! [String: AnyObject]
                        let job = Job()
                        
                        job.address = jobObject["jobAddress"] as! String
                        job.latitude = jobObject["latitude"] as! Double
                        job.longitude = jobObject["longitude"] as! Double
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
                        
                        self.pendingJobs.append(job)
                        self.table.reloadData()
                    })
                }
            }
        })
        
        
        
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyTableViewBackgroundColor(tableView: [table])
        theme.applyHeadlineStyle(labels: [userName])
        theme.applyBodyTextStyle(labels: [userEmail, userRating, userLocation, userDistance])
        theme.applySegmentedControlStyle(controls: [jobBar])
    }
    
}
