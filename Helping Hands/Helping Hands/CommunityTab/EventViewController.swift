//
//  EventViewController.swift
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
import UserNotifications

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, Themeable {
    
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventHelpers: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDistance: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var imgGradientView: UIView!
    @IBOutlet weak var eventDescriptionLBL: UILabel!
    @IBOutlet weak var attendeesLBL: UILabel!

    var eventID:String?
    var clearCore: Bool = false
    var event:Event?
    var attendees = [User]()
    var userAttendeeIdArray = [String]()
    var attendee: User!
    var chosen:Int?
    var e:Event!
    var locationManager = CLLocationManager()
    
    //Shared Notification Center
    let center = UNUserNotificationCenter.current()
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Theme
        ThemeService.shared.addThemeable(themable: self)

        table.dataSource = self
        table.delegate = self
        
        table.rowHeight = 73
        
        e = event
        
        // Set image
        let url = URL(string: e.imageAsString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                // Placeholder image
                self.eventPhoto.image = UIImage(named:"meeting")
                print("error downloading picture")
                return
            }
            self.eventPhoto.image = UIImage(data: data!)
        }
        
        // Not sure if this is too much, might not have to update this often
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        let distance = (locationManager.location?.distance(from: CLLocation(latitude: e.latitude, longitude: e.longitude)) as! Double) * 0.00062137
        eventDistance.text = String(format: "%.2f", distance) + " mi"
        
        // Set event labels
        eventTitle.text = e.eventTitle
        eventHelpers.text = String(e.numHelpers) + " Helpers"
        eventDate.text = e.eventDateString
        eventLocation.text = e.address
        eventDescription.text = e.eventDescription
        
        table.reloadData()
        
        let placeholderImage = UIImage(named: "meeting")
        self.eventPhoto.sd_setImage(with: URL(string: e.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
    }
    
    // EDIT WITH ALL FIELDS TAKEN FROM DATABASE
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem?.title = ""
        // retrieve attendees
        retrieveAttendees()
        
        // retrieve events
        retrieveEvents()
        
        // retrieve user for inquiry
        retrieveUser()
        
        let eventRef = databaseRef.child("events").child(eventID!)
        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let eventObject = snapshot.value as! [String: Any]
            
            if(eventObject["eventCreator"] as! String == self.userId) {
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }
            else {
                if(self.userAttendeeIdArray.contains(self.userId)) {
                    self.navigationItem.rightBarButtonItem = nil
                } else {
                    self.navigationItem.rightBarButtonItem?.title = "Sign-up"
                }
            }
            self.table.reloadData()
        })
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        let distance = (locationManager.location?.distance(from: CLLocation(latitude: e.latitude, longitude: e.longitude)) as! Double) * 0.00062137
        eventDistance.text = String(format: "%.2f", distance) + " mi"
        
        eventTitle.text = e.eventTitle
        eventHelpers.text = String(e.numHelpers) + " Helpers"
        eventDate.text = e.eventDateString
        eventLocation.text = e.address
        eventDescription.text = e.eventDescription
        
        table.reloadData()
        
    }
    
    // Set gradient background based on image colors
    override func viewDidLayoutSubviews() {
        let colors = eventPhoto.image?.getColors()
        
        let color1 = colors?.background
        let color2 = colors?.primary
        
        self.imgGradientView.setGradientBackground(colorOne: color1!, colorTwo: color2!)
        eventPhoto.layer.shadowColor = UIColor.black.cgColor
        eventPhoto.layer.shadowOpacity = 0.6
        eventPhoto.layer.shadowOffset = CGSize.zero
        eventPhoto.layer.shadowRadius = 8
        eventPhoto.layer.shouldRasterize = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        let row = indexPath.row
        let u:User = attendees[row]
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        cell.userImg.sd_setImage(with: URL(string: u.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
        cell.userImg.clipsToBounds = true
        cell.userImg.contentMode = .scaleAspectFill
        cell.userName.text = u.userFirstName + " " + u.userLastName
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        self.performSegue(withIdentifier: "showAttendee", sender: self)
    }
    
    @IBAction func addUser(_ sender: Any) {
        
        // Permissions check
        let eventRef = databaseRef.child("events").child(eventID!)
        let userRef = self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
        let usersAttendedRef = eventRef.child("usersAttendedArray")

        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let eventObject = snapshot.value as! [String: Any]
            // Take to editing screen if user is creator
            if(eventObject["eventCreator"] as! String == self.userId) {
                self.performSegue(withIdentifier: "showEventEditor", sender: self)
            }
            // Else sign up the user as an inquiry.
            else {
                self.retrieveUser()
                usersAttendedRef.observe(.value, with: { (snapshot_inquiry) in
                    if snapshot_inquiry.childrenCount > 0 {
                        print("inquiries not empty\n\n")
                        if(!self.userSignedUpForEvent(snapshot: snapshot_inquiry)) {
                            // User hasn't signed up already, approve inquiry request and update database
                            userRef.observeSingleEvent(of: .value, with: { (snapshot_usr) in
                                self.signUserUpForEvent()
                            })
                        }
                    } else {
                        print("inquiries empty\n\n")
                        self.signUserUpForEvent()
                    }
                })
            }
        })
    }
    
    // Sign users for event and update possible notifications.
    func signUserUpForEvent() {
        let eventRef = databaseRef.child("events").child(eventID!)
        let userRef = self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
        
        let userInquiredChild = eventRef.child("usersAttendedArray").childByAutoId()
        userInquiredChild.updateChildValues(["userId": self.userId])
        
        let eventInquiredChild = userRef.child("eventsAttendedArray").childByAutoId()
        eventInquiredChild.updateChildValues(["eventId": eventRef.key])
        self.navigationItem.rightBarButtonItem = nil
        self.table.reloadData()
        sendNotification()
    }

    // Check to see if the current user has already signed up for the job
    func userSignedUpForEvent(snapshot: FIRDataSnapshot) -> Bool {
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

    // ** SEGUE PREPARATION ** \\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showAttendee")
        {
            let u:User = attendees[chosen!]
            let destVC: UINavigationController = segue.destination as! UINavigationController
            let userVC:UserViewController =  destVC.topViewController as! UserViewController
            
            userVC.inquiryOrAttendee = true
            userVC.user = u
            userVC.userIndexPath = chosen!
        }
        if(segue.identifier == "showEventEditor")
        {
            let editorVC:EditEventViewController = segue.destination as! EditEventViewController
            editorVC.masterView = self
            editorVC.event = e
        }
    }
    // ** END SEGUE PREPARATION ** \\
    
    func getDate(date: NSDate) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MM/dd/yyyy"
        return dateFormate.string(from: date as Date)
    }
    
    func retrieveAttendees() {
        
        let usersAttendedRef = databaseRef.child("events").child(eventID!).child("usersAttendedArray")
        
        usersAttendedRef.observe(FIRDataEventType.value, with: {(snapshot) in
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                
                // for each snapshot (entity present under jobs child)
                for userAttendeesSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    // retrieve events and append to job list after creation
                    let attendeeObject = userAttendeesSnapshot.value as! [String: AnyObject]
                    let attendeeUserId = attendeeObject["userId"] as! String
                    let userRef = self.databaseRef.child("users").child(attendeeUserId)
                    
                    if(!self.userAttendeeIdArray.contains(attendeeUserId)) {
                        self.userAttendeeIdArray.append(attendeeUserId)
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            let userObject = snapshot.value as! [String : Any]
                            let user = User()
                            
                            user.userFirstName = userObject["firstName"] as! String
                            user.userLastName = userObject["lastName"] as! String
                            user.userEmail = userObject["email"] as! String
                            user.userJobsCompleted = userObject["jobsCompleted"] as! Int
                            user.userNumJobsPosted = userObject["jobsPosted"] as! Int
                            user.userMoneyEarned = userObject["moneyEarned"] as! Double
                            user.userPhotoAsString = userObject["photoUrl"] as! String
                            user.userID = attendeeUserId
                            
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
                            
                            self.attendees.append(user)
                            self.table.reloadData()
                        })
                    }
                }
                self.table.reloadData()
            }
        })
    }
    
    func retrieveEvents() {
        let eventRef = databaseRef.child("events").child(eventID!)
        
        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // retrieve jobs and append to job list after creation
            let eventObject = snapshot.value as! [String: AnyObject]
            let event = Event()
            
            event.address = eventObject["eventAddress"] as! String
            event.currentLocation = eventObject["eventCurrentLocation"] as! Bool
            event.eventDateString = eventObject["eventDate"] as! String
            event.eventDescription = eventObject["eventDescription"] as! String
            event.distance = eventObject["eventDistance"] as! Double
            event.imageAsString = eventObject["eventImageUrl"] as! String
            event.numHelpers = eventObject["eventNumHelpers"] as! Int
            event.eventTitle = eventObject["eventTitle"] as! String
            event.eventId = snapshot.ref.key
            
            self.event = event
            self.table.reloadData()
        })
    }
    
    // FIREBASE RETRIEVAL
    func retrieveUser() {
        let userRef = databaseRef.child("users").child(userId)
        
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
            
            self.attendee = user
        })
    }
    
    // Auxiliary getDate function
    func getDateFromString(str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' K:mm aaa"
        dateFormatter.timeZone = TimeZone(abbreviation: "CDT") //Current time zone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from:str)!
        return date
    }
    

    // If notifications are on, then send reminder based on event date.
    func sendNotification() {
        let userSettingOn: Bool = UserDefaults.standard.bool(forKey: "event_reminders_notif")
        if !userSettingOn {
            print("User's settings for notifications are off\n\n")
            return
        }
        self.center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
                UserDefaults.standard.set(false, forKey: "event_reminders_notif")
            } else {
                // Notifications allowed
                print("Authorized\n\n")
                let content = UNMutableNotificationContent()
                content.title = "Reminder"
                content.body = "You have an event coming up!"
                content.sound = UNNotificationSound.default()
                // User recieves a notification 1 day prior to a pending job
                let date = Calendar.current.date(byAdding: .day, value: -1, to: self.getDateFromString(str: (self.e?.eventDateString!)!))
                let df = DateFormatter()
                df.dateFormat = "MMM dd, yyyy 'at' K:mm aaa"
                df.timeZone = TimeZone(abbreviation: "CDT")
                print("\nSending User Notification at \(df.string(from: date!))")
                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date!)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let identifier = self.e?.eventId
                let request = UNNotificationRequest(identifier: identifier!, content: content, trigger: trigger)
                self.center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        // Something went very wrong
                        print("Notification Error: \(error)\n\n\n")
                    }
                })
            }
        }
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, imgGradientView])
        theme.applyHeadlineStyle(labels: [eventTitle, eventDescriptionLBL, attendeesLBL])
        theme.applyBodyTextStyle(labels: [eventDate, eventLocation, eventDistance, eventDescription])
        theme.applyTableViewBackgroundColor(tableView: [table])
    }
    
}
