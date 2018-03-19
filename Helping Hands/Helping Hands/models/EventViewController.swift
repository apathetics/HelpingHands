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
    
    var masterView:CommunityTabViewController?
    var clearCore: Bool = false
    var event:NSManagedObject?
    
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventHelpers: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDistance: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventAttendees: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        return cell
    }
    
    @IBOutlet weak var table: UITableView!
    /*
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return inquiries.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell:eventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! eventTableViewCell
     
     let row = indexPath.row
     let j:NSManagedObject = inquiries[row]
     
     cell.eventTitleLbl.text = j.value(forKey: "eventTitle") as? String
     cell.eventDescriptionLbl.text = j.value(forKey: "eventDescription") as? String
     cell.distanceLbl.text = String(j.value(forKey: "eventDistance") as! Double) + " mi"
     let ftmPayment = "$" + ((j.value(forKey: "eventPayment") as! Double).truncatingRemainder(dividingBy: 1) == 0 ? String(j.value(forKey: "eventPayment") as! Int64) : String(j.value(forKey: "eventPayment") as! Double))
     print("PAYMENT IS:", ftmPayment)
     cell.paymentLbl.text = j.value(forKey: "eventIsHourlyPaid") as! Bool == true ? ftmPayment + "/hr" : ftmPayment
     cell.eventImg.image = UIImage(data: j.value(forKey: "eventImage") as! Data)
     
     return cell
     }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventPhoto.image = UIImage(data: event?.value(forKey: "eventImage") as! Data)
        eventTitle.text = event?.value(forKey: "eventTitle") as? String
        eventHelpers.text = String(event?.value(forKey: "eventNumHelpers") as! Int64) + " Helpers"
        eventDate.text = getDate(date: event?.value(forKey:"eventDate") as! NSDate)
        eventDistance.text = String(event?.value(forKey: "eventDistance") as! Double) + " mi"
        
        // To be done when location is more than an illusion
        //if(event?.value(forKey: "currentLocation") as! Bool) {
        eventLocation.text = "curLocation"
        //}
        /*
         else {
         eventLocation.text = event?.value(forKey: "eventLocation") as? String
         }
         */
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
    
    /*
     override func viewWillAppear(_ animated: Bool) {
     inquiries = [NSManagedObject]()
     
     for event in retrieveinquiries() {
     inquiries.append(event)
     }
     
     //table.reloadData()
     }*/
    /*
     func retrieveinquiries() -> [NSManagedObject] {
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let context = appDelegate.persistentContainer.viewContext
     
     let request = NSFetchRequest<NSFetchRequestResult>(entityName:"eventEntity")
     var fetchedResults:[NSManagedObject]? = nil
     
     // Examples of filtering using predicates
     // let predicate = NSPredicate(format: "age = 35")
     // let predicate = NSPredicate(format: "name CONTAINS[c] 'ake'")
     // request.predicate = predicate
     
     do {
     try fetchedResults = context.fetch(request) as? [NSManagedObject]
     } catch {
     // If an error occurs
     let nserror = error as NSError
     NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
     abort()
     }
     
     return(fetchedResults)!
     
     }
     
     func clearCoreevent() {
     
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let context = appDelegate.persistentContainer.viewContext
     
     let request = NSFetchRequest<NSFetchRequestResult>(entityName: "eventEntity")
     var fetchedResults:[NSManagedObject]
     
     do {
     try fetchedResults = context.fetch(request) as! [NSManagedObject]
     
     if fetchedResults.count > 0 {
     
     for result:AnyObject in fetchedResults {
     context.delete(result as! NSManagedObject)
     print("\(result.value(forKey: "eventTitle")!) has been Deleted")
     }
     }
     try context.save()
     
     } catch {
     // If an error occurs
     let nserror = error as NSError
     NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
     abort()
     }
     
     }
     */
}
