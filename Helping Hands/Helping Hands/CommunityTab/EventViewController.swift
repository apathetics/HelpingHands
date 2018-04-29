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
    var attendee: User!
    var chosen:Int?
    var e:Event!
    var locationManager = CLLocationManager()
    
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
    
    override func viewDidAppear(_ animated: Bool) {
        let eventRef = databaseRef.child("events").child(eventID!)
        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let eventObject = snapshot.value as! [String: Any]
            if(eventObject["eventCreator"] as! String == self.userId) {
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }
            self.table.reloadData()
        })
        table.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)

        table.dataSource = self
        table.delegate = self
        
        e = event
        
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
                self.navigationItem.rightBarButtonItem?.title = "Sign-up"
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
        
//        cell.userImg.image = u.userPhoto
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        cell.userImg.sd_setImage(with: URL(string: u.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
    
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
        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let eventObject = snapshot.value as! [String: Any]
            
            if(eventObject["eventCreator"] as! String == self.userId) {
                self.performSegue(withIdentifier: "showEventEditor", sender: self)
            }
            else {
                self.retrieveUser()
                
                // Save job inquiry
                let userRef = self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
                userRef.observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    let eventInquiredChild = userRef.child("eventsAttendedArray").childByAutoId()
                    eventInquiredChild.updateChildValues(["eventId": eventRef.key])
                })
                
                let userInquiredChild = eventRef.child("usersAttendedArray").childByAutoId()
                userInquiredChild.updateChildValues(["userId": self.userId])
                
                self.attendees.append(self.attendee)
                self.table.reloadData()
            }
            self.table.reloadData()
        })
        self.table.reloadData()
    }
    
    // ** SEGUE PREPARATION ** \\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showAttendee")
        {
            let j:User = attendees[chosen!]
            let userVC:UserViewController = segue.destination as! UserViewController
            userVC.user = j
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
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let eventsRef = databaseRef.child("events")
        let usersAttendedRef = eventsRef.child(eventID!).child("usersAttendedArray")
        
        var userAttendeeIdArray = [String]()
        
        usersAttendedRef.observe(FIRDataEventType.value, with: {(snapshot) in
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                
                // clear job list before appending again
                self.attendees.removeAll()
                userAttendeeIdArray.removeAll()
                
                // for each snapshot (entity present under jobs child)
                for userAttendeesSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    // retrieve jobs and append to job list after creation
                    let attendeeObject = userAttendeesSnapshot.value as! [String: AnyObject]
                    
                    let attendeeUserId = attendeeObject["userId"] as! String
                    
                    userAttendeeIdArray.append(attendeeUserId)
                    
                }
                
                for userAttendeeId in userAttendeeIdArray {
                    
                    let userRef = databaseRef.child("users").child(userAttendeeId)
                    
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
                        
                        //                        user.userID = self.userId
                        
                        self.attendees.append(user)
                        self.table.reloadData()
                    })
                }
                self.table.reloadData()
            }
        })
        
    }
    
    func retrieveEvents() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
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
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
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
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, imgGradientView])
        theme.applyHeadlineStyle(labels: [eventTitle, eventDescriptionLBL, attendeesLBL])
        theme.applyBodyTextStyle(labels: [eventDate, eventLocation, eventDistance, eventDescription])
        theme.applyTableViewBackgroundColor(tableView: [table])
    }
    
}
