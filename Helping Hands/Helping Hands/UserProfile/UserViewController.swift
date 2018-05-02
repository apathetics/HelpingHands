//
//  UserViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorageUI

class UserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, Themeable {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var jobBar: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var starIcon: UIImageView!
    @IBOutlet weak var bioLBL: UILabel!
    
    let manager = CLLocationManager()
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
    
    var imgChosen = false
    var user:User!
    var userIndexPath:Int?
    var inquiryOrAttendee = false
    
    var postedJobs = [Job]()
    var pendingJobs = [Job]()
    var completedJobs = [Job]()
    
    var chosen: Int?
    var chosenPostedJob: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load theme
        ThemeService.shared.addThemeable(themable: self)
        
        table.delegate = self
        table.dataSource = self
        
        self.table.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // retrieve job statuses before loading
        retrieveJobStatuses()
        
        // retrieve user info before loading
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
        
        // set user data in labels
        userPhoto.layer.cornerRadius = userPhoto.frame.height/2
        userPhoto.contentMode = .scaleAspectFill
        userPhoto.clipsToBounds = true
        
        userName.text = (user.userFirstName)! + " " + (user?.userLastName)!
        userEmail.text = user.userEmail
        userDescription.text = user.userBio
        
        self.table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // pass information for when we edit the user
        if(segue.identifier == "showEditUser")
        {
            let editorVC:EditUserViewController = segue.destination as! EditUserViewController
            editorVC.masterView = self
            print(user.userFirstName)
            editorVC.user = user
        }

        // pass information for when we go to the QR code page
        if(segue.identifier == "showConfirmationHirer") {
            let vc:QRViewController = segue.destination as! QRViewController
            vc.chosenJobId = self.chosenPostedJob.jobId
        }
    }
    
    // reload table data on changing segment
    @IBAction func segmentControlActionChanged(_ sender: Any) {
        self.table.reloadData()
    }
    
    // ** START TABLE FUNCTIONS ** \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var selectedJobCount = 0
        
        // switch to handle different type of job views in the table
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
        
        // set various different views depending on the type of job (posted/pending are the same but completed is different)
        switch(jobBar.selectedSegmentIndex) {
        case 0:
            
            // grab the chosen job
            j = postedJobs[row]
            
            // populate the cell with its data
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
            
            // populate less info than its other two categories
            cell.jobTitleLbl.text = j!.jobTitle
            cell.jobDescriptionLbl.text = j!.jobReview
            cell.paymentLbl.text = String(Int(j!.jobRating)) + "/5"
            
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
        
        // here we want to define how to segue into the QR/scanner screen for when we click an instance of a job we want to complete
        switch(jobBar.selectedSegmentIndex) {
        case 0:
            // for the QR code, we want to update the QR flag
            chosenPostedJob = postedJobs[row]
            let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
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
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
        var userRef = databaseRef.child("users").child(self.userId)
        
        if self.inquiryOrAttendee {
            userRef = databaseRef.child("users").child(user.userID)
        }

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
            
            // set user ID to given id to prevent incorrect user instance view
            user.userID = self.userId
            
            self.user = user
        })
    }
    
    func retrieveJobStatuses() {
        
        // retrieve location
        let locationManager = self.manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
        var currentUserRef = databaseRef.child("users").child(self.userId)
    
        if self.inquiryOrAttendee {
            currentUserRef = databaseRef.child("users").child(user.userID)
        }
        
        // we want to keep track of the three different type of jobs to feed into the switch case
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
                
                for jobId in postedJobsId {
                    let jobRef = databaseRef.child("jobs").child(jobId)
                    
                    jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot == nil {
                            print("Error: Something went wrong")
                            return
                        }
                        // retrieve jobs and append to job list after creation
                        // TODO: Bug seems to be happening here? Not sure why, but I can't open up my user profile - Bryan
                        // Synchronization is hard. + 1 usually works but + 2 works for sure on slow internets.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
                            
                        let distance = (locationManager.location?.distance(from: CLLocation(latitude: job.latitude, longitude: job.longitude)) as! Double) * 0.00062137
                        
                        job.distance = distance

                        self.postedJobs.append(job)
                        self.table.reloadData()
                        }
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

                        let distance = (locationManager.location?.distance(from: CLLocation(latitude: job.latitude, longitude: job.longitude)) as! Double) * 0.00062137

                        job.distance = distance
                        
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
                
                for jobId in completedJobsId {
                    let jobRef = databaseRef.child("completedJobs").child(jobId)
                    
                    jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        
                        // retrieve jobs and append to job list after creation
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
        theme.applyBodyTextStyle(labels: [userEmail, userRating])
        theme.applySegmentedControlStyle(controls: [jobBar])
        theme.applyIconStyle(icons: [starIcon])
        theme.applyTextViewStyle(textViews: [userDescription])
    }
    
}
