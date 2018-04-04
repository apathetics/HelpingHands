//
//  EventViewController.swift
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

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Themeable {
    
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventHelpers: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDistance: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventAttendees: UITableView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var imgGradientView: UIView!
    
    @IBOutlet weak var descLBL: UILabel!
    @IBOutlet weak var attendeesLBL: UILabel!
    
    
    
    var masterView:CommunityTabViewController?
    var eventID:String?
    var clearCore: Bool = false
    var event:Event?
    var attendees = [User]()
    var chosen:Int?
    var e:Event!
    
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
        let eventRef = databaseRef.child("events").child(eventID!)
        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let eventObject = snapshot.value as! [String: Any]
            
            if(eventObject["eventCreator"] as! String == self.userId) {
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }
            self.table.reloadData()
        })
        
        eventPhoto.image = e.image
        eventTitle.text = e.eventTitle
        eventHelpers.text = String(e.numHelpers) + " Helpers"
        eventDate.text = e.eventDateString
        eventDistance.text = String(e.distance) + " mi"
        
        // TODO when location is more than an illusion
        eventLocation.text = e.address
        
        eventDescription.text = e.eventDescription
    }
    
    // EDIT WITH ALL FIELDS TAKEN FROM DATABASE
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveEvents()
        
        let eventRef = databaseRef.child("events").child(eventID!)
        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let eventObject = snapshot.value as! [String: Any]

            if(eventObject["eventCreator"] as! String == self.userId) {
                self.navigationItem.rightBarButtonItem?.title = "Edit"
            }
            self.table.reloadData()
        })
        
        let placeholderImage = UIImage(named: "meeting")
        self.eventPhoto.sd_setImage(with: URL(string: e.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
//        eventPhoto.image = e.image
        eventTitle.text = e.eventTitle
        eventHelpers.text = String(e.numHelpers) + " Helpers"
        eventDate.text = e.eventDateString
        eventDistance.text = String(e.distance) + " mi"
        
        // TODO when location is more than an illusion
        eventLocation.text = "curLocation"
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
        
        cell.userImg.image = u.userPhoto
        cell.userName.text = u.userFirstName + " " + u.userLastName
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        
        /*
        self.performSegue(withIdentifier: "showAttendee", sender: self)
        */
    }
    
    @IBAction func rightButtonPress(_ sender: Any) {
        let eventRef = databaseRef.child("events").child(eventID!)
        eventRef.observeSingleEvent(of: .value, with: {(snapshot) in
            let eventObject = snapshot.value as! [String: Any]
            
            if(eventObject["eventCreator"] as! String == self.userId) {
                self.performSegue(withIdentifier: "showEventEditor", sender: self)
            }
            else {
                let attendee:User = User()
                attendee.userFirstName = "Emiliano"
                attendee.userLastName = "Zapata"
                attendee.userPhoto = UIImage()
                attendee.userBio = "I like being a revolutionary, it's fun."
                attendee.userEmail = "porfirioHater1912@mexico.com"
                attendee.userLocationRadius = 0.0
                attendee.userNumJobsPosted = 1
                attendee.userNumJobsPending = 2
                attendee.userJobsCompleted = 4
                
//                attendee.userID = self.attendees.count
                
                self.attendees.append(attendee)
                self.table.reloadData()
            }
            self.table.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showAttendee")
        {
            /*
            let j:User = attendees[chosen!]
            let userVC:UserViewController = segue.destination as! UserViewController
            userVC.masterView = self
            userVC.user = j
            userVC.userIndexPath = chosen!
            */
 
        }
        if(segue.identifier == "showEventEditor")
        {
            let editorVC:EditEventViewController = segue.destination as! EditEventViewController
            editorVC.masterView = self
            editorVC.event = e
        }
    }
    
    func getDate(date: NSDate) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MM/dd/yyyy"
        return dateFormate.string(from: date as Date)
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
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, imgGradientView])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTableViewBackgroundColor(tableView: table)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyHeadlineStyle(labels: [eventTitle, attendeesLBL, descLBL])
        theme.applyBodyTextStyle(labels: [eventDate, eventDistance, eventLocation, eventDescription])
    }
    
}
