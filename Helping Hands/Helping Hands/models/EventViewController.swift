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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventPhoto.image = UIImage(data: event?.value(forKey: "eventImage") as! Data)
        eventTitle.text = event?.value(forKey: "eventTitle") as? String
        eventHelpers.text = String(event?.value(forKey: "eventNumHelpers") as! Int64) + " Helpers"
        eventDate.text = getDate(date: event?.value(forKey:"eventDate") as! NSDate)
        eventDistance.text = String(event?.value(forKey: "eventDistance") as! Double) + " mi"
        
        // TODO when location is more than an illusion
        eventLocation.text = "curLocation"
        
        eventDescription.text = event?.value(forKey: "eventDescription") as? String
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
         if clearCore {
         clearCoreevent()
         }*/
        
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
    
}
