//
//  CommunityTabViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/1/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class CommunityTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // If need to clear event core, then set this flag to true.
    let clearCore: Bool = false
    
    var eventToAdd:Event?
    var events = [NSManagedObject]()
    var chosen:Int?
    
    @IBOutlet weak var table: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        let row = indexPath.row
        let e:NSManagedObject = events[row]
        
        cell.eventTitleLbl.text = e.value(forKey: "eventTitle") as? String
        cell.eventDescriptionLbl.text = e.value(forKey: "eventDescription") as! String
        cell.distanceLbl.text = String(e.value(forKey: "eventDistance") as! Double) + " mi"
        cell.eventImg.image = UIImage(data: e.value(forKey: "eventImage") as! Data)
        cell.helpersLbl.text = String(e.value(forKey: "eventNumHelpers") as! Int64) + " Helper"
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // CLEAR CORE HERE IF FLAG
        if clearCore {
        clearCoreEvent()
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        self.performSegue(withIdentifier: "showEvent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addEvent")
        {
            let addEventVC:AddEventViewController = segue.destination as! AddEventViewController
            addEventVC.masterView = self
        }
        if(segue.identifier == "showEvent")
        {
            let e:NSManagedObject = events[chosen!]
            let eventVC:EventViewController = segue.destination as! EventViewController
            eventVC.masterView = self
            eventVC.event = e
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        events = [NSManagedObject]()
        
        for event in retrieveEvents() {
            events.append(event)
        }
        
        table.reloadData()
    }
    
    func retrieveEvents() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"EventEntity")
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
    
    func clearCoreEvent() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
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
    
}
