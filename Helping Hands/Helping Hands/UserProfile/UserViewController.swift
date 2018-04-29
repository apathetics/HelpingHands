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
    @IBOutlet weak var starIcon: UIImageView!
    @IBOutlet weak var bioLBL: UILabel!
    
    
    
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
    
    var imgChosen = false
    var user:User!
    var userIndexPath:Int?
    
    var postedJobs = [Job]()
    var pendingJobs = [Job]()
    var completedJobs = [Job]()
    
    var chosen: Int?
    
    var chosenPostedJob: Job!
    
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
        
        // check for user permissions to edit
        if(user.userEmail != FIRAuth.auth()?.currentUser?.email) {
            //print("\nchecking out different user's profile\n")
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem?.title =  "Edit";
        }
        
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        self.userPhoto.sd_setImage(with: URL(string: self.user.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })

        userPhoto.contentMode = .scaleAspectFill
        userPhoto.clipsToBounds = true

        userName.text = (user.userFirstName)! + " " + (user?.userLastName)!
        userEmail.text = user.userEmail
        userDescription.text = user.userBio
        
        // Change the ones below
        userLocation.text = String(describing: user.userLocationRadius!)
        userDistance.text = String(describing: user.userDistance!)
        //        userRating.text = String(user.userRating!)
        
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
        if(segue.identifier == "showConfirmationHirer") {
            let vc:QRViewController = segue.destination as! QRViewController
            vc.chosenJobId = self.chosenPostedJob.jobId
        }
    }
    
    @IBAction func segmentControlActionChanged(_ sender: Any) {
        self.table.reloadData()
    }
    
    // ** START TABLE FUNCTIONS ** \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var selectedJobCount = 0
        
        switch(self.jobBar.selectedSegmentIndex) {
        case 0:
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
            break
            
        case 1:
            j = pendingJobs[row]
            
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
            break
            
        case 2:
            j = completedJobs[row]
            
            cell.jobTitleLbl.text = j!.jobTitle
            cell.jobDescriptionLbl.text = j!.jobReview
            cell.paymentLbl.text = String(Int(j!.jobRating)) + "/5"
            cell.distanceLbl.isHidden = true
            
            let placeholderImage = UIImage(named: "meeting")
            cell.jobImg.sd_setImage(with: URL(string: j!.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            })
            break
            
        default:
            break
        }
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        
        switch(jobBar.selectedSegmentIndex) {
        case 0:
            chosenPostedJob = postedJobs[row]
            let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
            let jobRef = databaseRef.child("jobs").child(chosenPostedJob.jobId)
            jobRef.updateChildValues(["QRCodeFlag": true])
            self.performSegue(withIdentifier: "showConfirmationHirer", sender: self)
            break
        case 1:
            self.performSegue(withIdentifier: "showConfirmationHired", sender: self)
            break
            
        case 2:
            break
            
        default:
            break
        }

    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onEditButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditUser", sender: self)
    }
    
    // FIREBASE RETRIEVAL
    func retrieveUser() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
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
            user.userRating = userObject["userRating"] as? Double
            
            if(user.userRating != nil) {
                self.userRating.text = String(user.userRating!)
            }
            else {
                self.userRating.text = "5.0"
            }
            
            if(userObject["bio"] as? String == nil || userObject["bio"] as! String == "") {
                user.userBio = "Description..."
            }
            else {
                user.userBio = userObject["bio"] as! String
            }
            
            //TODO: SETTINGS NOT IN DATABASE YET
            user.userLocationRadius = 1
            user.userDistance = 1
            
            //FIX: self.userId is current logged in user's id. This could be different from the userId of the profile we're visiting if that profile is a different person.
            user.userID = self.userId
            
            self.user = user
        })
    }
    
    func retrieveJobStatuses() {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
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
                        // TODO: Bug seems to be happening here? Not sure why, but I can't open up my user profile - Bryan
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
                        job.jobCreator = jobObject["jobCreator"] as! String
                        
                        self.pendingJobs.append(job)
                        self.table.reloadData()
                    })
                }
            }
        })
        
        // JOBS COMPLETED ARRAY
        currentUserRef.child("jobsCompletedArray").observe(FIRDataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                for jobsCompletedSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    let jobsCompletedObject = jobsCompletedSnapshot.value as! [String: AnyObject]
                    
                    let jobId = jobsCompletedObject["jobId"] as! String
                    completedJobsId.append(jobId)
                }
                print("I AM COMPLETED JOBS IDS: ", completedJobsId)
                
                for jobId in completedJobsId {
                    let jobRef = databaseRef.child("completedJobs").child(jobId)
                    
                    jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        
                        // retrieve jobs and append to job list after creation
                        // TODO: Bug seems to be happening here? Not sure why, but I can't open up my user profile - Bryan
                        let jobObject = snapshot.value as! [String: AnyObject]
                        let job = Job()
                        
                        job.jobDescription = jobObject["jobDescription"] as! String
                        job.payment = jobObject["jobPayment"] as! Double
                        job.jobRating = jobObject["jobRating"] as! Double
                        job.jobReview = jobObject["jobReview"] as! String
                        job.jobTitle = jobObject["jobTitle"] as! String
                        job.imageAsString = jobObject["jobImageUrl"] as! String
                        
                        self.completedJobs.append(job)
                        self.table.reloadData()
                    })
                }
            }
        })
        
        
        
    }
    
    func applyTheme(theme: Theme) {
        if(self.navigationController == nil) {
            // big fix: UserVC->navigationController is nil after clicking back button
            UINavigationController(rootViewController: self)
        }
        theme.applyBackgroundColor(views: [view])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyTableViewBackgroundColor(tableView: [table])
        theme.applyHeadlineStyle(labels: [userName, bioLBL])
        theme.applyBodyTextStyle(labels: [userEmail, userRating, userLocation, userDistance])
        theme.applySegmentedControlStyle(controls: [jobBar])
        theme.applyIconStyle(icons: [starIcon])
        theme.applyTextViewStyle(textViews: [userDescription])
    }
    
}
