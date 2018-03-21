//
//  EventViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventHelpers: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDistance: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventAttendees: UITableView!
    @IBOutlet weak var table: UITableView!
    
    var masterView:CommunityTabViewController?
    var clearCore: Bool = false
    var event:NSManagedObject?
    var e:Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        e = convertEvent()
        eventPhoto.image = e.image
        eventTitle.text = e.eventTitle
        eventHelpers.text = String(e.numHelpers) + " Helpers"
        eventDate.text = getDate(date: e.date as NSDate)
        eventDistance.text = String(e.distance) + " mi"
        
        // TODO when location is more than an illusion
        eventLocation.text = "curLocation"
        
        eventDescription.text = e.eventDescription
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
         if clearCore {
         clearCoreevent()
         }*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        eventPhoto.image = e.image
        eventTitle.text = e.eventTitle
        eventHelpers.text = String(e.numHelpers) + " Helpers"
        eventDate.text = getDate(date: e.date as NSDate)
        eventDistance.text = String(e.distance) + " mi"
        
        // TODO when location is more than an illusion
        eventLocation.text = "curLocation"
        eventDescription.text = e.eventDescription
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showEditEvent")
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
    
    func convertEvent() -> Event {
        let e = Event()
        e.image = UIImage(data: event?.value(forKey: "eventImage") as! Data)
        e.eventTitle = event?.value(forKey: "eventTitle") as? String
        e.numHelpers = event?.value(forKey: "eventNumHelpers") as! Int
        e.date = event?.value(forKey:"eventDate") as! Date
        e.distance = event?.value(forKey: "eventDistance") as! Double
        e.eventDescription = event?.value(forKey: "eventDescription") as? String
        return e
    }
    
}
