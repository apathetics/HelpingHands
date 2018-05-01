//
//  JobViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import FirebaseStorageUI
import FirebaseAuth
import FirebaseDatabase
import UIImageColors

class JobViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, Themeable {
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var imgGradientView: UIView!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDate: UILabel!
    @IBOutlet weak var jobPrice: UILabel!
    @IBOutlet weak var jobLocation: UILabel!
    @IBOutlet weak var jobDistance: UILabel!
    @IBOutlet weak var jobDescription: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var signUpButton: UIBarButtonItem!
    
    @IBOutlet weak var descriptionLBL: UILabel!
    @IBOutlet weak var inquiriesLBL: UILabel!
    
    var jobID:String?
    var clearCore: Bool = false
    var job:Job?
    var inquiries = [User]()
    var userInquiryIdArray = [String]()
    var chosen:Int?
    var j:Job!
    var inquiry:User!
    var locationManager = CLLocationManager()
    
    var inquiriesArray: [String]!
    
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        
        table.dataSource = self
        table.delegate = self
        
        table.rowHeight = 73
        
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
        
        // Not sure if this is too much, might not have to update this often
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        let distance = (locationManager.location?.distance(from: CLLocation(latitude: j.latitude, longitude: j.longitude)) as! Double) * 0.00062137
        jobDistance.text = String(format: "%.2f", distance) + " mi"
        
        jobTitle.text = j.jobTitle
        let ftmPayment = "$" + (j.payment.truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        jobPrice.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        jobDate.text = j.jobDateString
        jobLocation.text = j.address
        jobDescription.text = j.jobDescription
        
        
        // load image
        let placeholderImage = UIImage(named: "meeting")
        self.jobPhoto.sd_setImage(with: URL(string: j.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        
        table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // retrieve inquiries
        retrieveInquiries()
        
        // retrieve jobs
        retrieveJob()
        
        // retrieve user for inquiry
        retrieveUser()
        
        let jobRef = databaseRef.child("jobs").child(jobID!)
        jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let jobObject = snapshot.value as! [String: Any]
            
            if(jobObject["jobCreator"] as! String == self.userId) {
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }
            else {
                if(self.userInquiryIdArray.contains(self.userId)) {
                    self.navigationItem.rightBarButtonItem = nil
                    print("hide button")
                } else {
                    self.navigationItem.rightBarButtonItem?.title = "Sign-up"
                }
            }
            self.table.reloadData()
        })
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        let distance = (locationManager.location?.distance(from: CLLocation(latitude: j.latitude, longitude: j.longitude)) as! Double) * 0.00062137
        jobDistance.text = String(format: "%.2f", distance) + " mi"
        
        jobTitle.text = j.jobTitle
        let ftmPayment = "$" + (j.payment.truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        jobPrice.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        jobDate.text = j.jobDateString
        jobLocation.text = j.address
        jobDescription.text = j.jobDescription
        
        table.reloadData()
    }
    
    // ** STANDARD TABLE FUNCTIONS ** \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inquiries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        let row = indexPath.row
        let u:User = inquiries[row]
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        cell.userImg.sd_setImage(with: URL(string: u.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
        cell.userImg.clipsToBounds = true
        cell.userImg.contentMode = .scaleAspectFill
//        cell.userImg.image = u.userPhoto
        cell.userName.text = u.userFirstName + " " + u.userLastName
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        
        self.performSegue(withIdentifier: "showInquiry", sender: self)
    }
    // ** END STANDARD TABLE FUNCTIONS ** \\
    
    // ** SEGUE PREPARATION ** \\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showInquiry")
        {
            let u:User = inquiries[chosen!]
            let destVC: UINavigationController = segue.destination as! UINavigationController
            let userVC:UserViewController = destVC.topViewController as! UserViewController
            
            userVC.inquiryOrAttendee = true
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
    // ** END SEGUE PREPARATION ** \\
    
    
    
    // Either show editing screen if permissions check out or "sign-up" the user to table cell (right nav button)
    @IBAction func addUser(_ sender: Any) {
        
        // Permissions check
        let jobRef = databaseRef.child("jobs").child(jobID!)
        let userRef = self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
        let usersInquiredRef = jobRef.child("usersInquiredArray")
        
        jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let jobObject = snapshot.value as! [String: Any]
            
            // Take to editing screen if user is creator
            if(jobObject["jobCreator"] as! String == self.userId) {
                self.performSegue(withIdentifier: "showJobEditor", sender: self)
            }
            // Else sign up the user as an inquiry.
            else {
                self.retrieveUser()
                usersInquiredRef.observe(FIRDataEventType.value, with: { (snapshot_inquiry) in
                    if snapshot_inquiry.childrenCount > 0 {
                        print("inquiries not empty\n\n")
                        if (!self.userSignedUpForJob(snapshot: snapshot_inquiry)) {
                            // User hasn't signed up already, approve inquiry request and update database
                            userRef.observeSingleEvent(of: .value, with: {(snapshot_usr) in
                                self.signUserUpForJob()
                                self.navigationItem.rightBarButtonItem = self.signUpButton
                                self.table.reloadData()
                            })
                        } else {
                        }
                    } else {
                        print("inquiries empty\n\n")
                        self.signUserUpForJob()
                    }
                })
            }
        })
    }
    
    func signUserUpForJob() {
        let jobRef = databaseRef.child("jobs").child(jobID!)
        let userRef = self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)

        let jobInquiredChild = userRef.child("jobsInquiredArray").childByAutoId()
        jobInquiredChild.updateChildValues(["jobId": jobRef.key])
        
        let userInquiredChild = jobRef.child("usersInquiredArray").childByAutoId()
        userInquiredChild.updateChildValues(["userId": self.userId])
        self.navigationItem.rightBarButtonItem = nil
    }
    
    // Check to see if the current user has already signed up for the job
    func userSignedUpForJob(snapshot: FIRDataSnapshot) -> Bool {
        for inquiry in snapshot.children.allObjects as! [FIRDataSnapshot] {
            let inquiryObj = inquiry.value as! [String:AnyObject]
            let inquiryUserId = inquiryObj["userId"] as! String
            if(inquiryUserId == self.userId) {
                // Don't add user again (duplicate)
                print("User already signed up for this job!\n\n")
                self.navigationItem.rightBarButtonItem = nil
                // exit logic
                return true
            }
        }
        print("User not yet signed up for this job!\n\n")
        return false
    }
    
    // Auxiliary getDate function
    func getDate(date: NSDate) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MM/dd/yyyy"
        return dateFormate.string(from: date as Date)
    }
    
    // FIREBASE RETRIEVAL
    func retrieveUser() {
        let userRef = databaseRef.child("users").child(self.userId)
        
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            let user = User()
            // retrieve jobs and append to job list after creation
            let userObject = snapshot.value as! [String: AnyObject]
            
            
            user.userFirstName = userObject["firstName"] as! String
            user.userLastName = userObject["lastName"] as! String
            user.userEmail = userObject["email"] as! String
            user.userJobsCompleted = userObject["jobsCompleted"] as! Int
            user.userNumJobsPosted = userObject["jobsPosted"] as! Int
            user.userMoneyEarned = userObject["moneyEarned"] as! Double
            user.userPhotoAsString = userObject["photoUrl"] as! String
            
            let placeholderImageView = UIImageView()
            
            // Placeholder image
            let placeholderImage = UIImage(named: "meeting")
            // Load the image using SDWebImage
            placeholderImageView.sd_setImage(with: URL(string: user.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                user.userPhoto = image
            })
            
            
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
            
            self.inquiry = user
        })
    }
    
    // FIREBASE RETRIEVAL
    func retrieveJob() {
        let jobRef = databaseRef.child("jobs").child(jobID!)
        
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
    
            self.job = job
            self.table.reloadData()
        })
    }
    
    func retrieveInquiries() {

        let usersInquiredRef = databaseRef.child("jobs").child(jobID!).child("usersInquiredArray")

        usersInquiredRef.observe(FIRDataEventType.value, with: {(snapshot) in

            // make sure there are jobs
            if snapshot.childrenCount > 0 {

                // for each snapshot (entity present under jobs child)
                for userInquiriesSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {

                    // retrieve jobs and append to job list after creation
                    let inquiryObject = userInquiriesSnapshot.value as! [String: AnyObject]
                    let inquiryUserId = inquiryObject["userId"] as! String
                    let userRef = self.databaseRef.child("users").child(inquiryUserId)
                    
                    if(!self.userInquiryIdArray.contains(inquiryUserId)) {
                        self.userInquiryIdArray.append(inquiryUserId)
                        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
                            // retrieve jobs and append to job list after creation
                            let userObject = snapshot.value as! [String : Any]
                            let user = User()
                            
                            user.userFirstName = userObject["firstName"] as! String
                            user.userLastName = userObject["lastName"] as! String
                            user.userEmail = userObject["email"] as! String
                            user.userJobsCompleted = userObject["jobsCompleted"] as! Int
                            user.userNumJobsPosted = userObject["jobsPosted"] as! Int
                            user.userMoneyEarned = userObject["moneyEarned"] as! Double
                            user.userPhotoAsString = userObject["photoUrl"] as! String
                            user.userID = inquiryUserId
                            
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
                            
                            self.inquiries.append(user)
                            self.table.reloadData()
                        })
                    }
                }
                self.table.reloadData()
            }
        })

    }

    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, imgGradientView])
        theme.applyHeadlineStyle(labels: [jobTitle, descriptionLBL, inquiriesLBL])
        theme.applyBodyTextStyle(labels: [jobDate, jobLocation, jobDistance, jobDescription, jobDate])
        theme.applyTableViewBackgroundColor(tableView: [table])
    }
}
