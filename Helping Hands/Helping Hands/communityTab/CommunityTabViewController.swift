//
//  CommunityTabViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/1/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class CommunityTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var eventToAdd:Event?
    var events = [Event]()
    
    
    @IBOutlet weak var table: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        let row = indexPath.row
        let e:Event = events[row]
        
        cell.eventTitleLbl.text = e.eventTitle
        cell.eventDescriptionLbl.text = e.eventDescription
        cell.distanceLbl.text = String(e.distance!) + " mi"
        cell.eventImg.image = e.image
        cell.helpersLbl.text = String(e.numHelpers) + " Helpers"
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addEventVC:AddEventViewController = segue.destination as! AddEventViewController
        addEventVC.masterView = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (eventToAdd != nil) {
            events.insert(eventToAdd!, at: 0)
            eventToAdd = nil
            table.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            table.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .none)
        }
        
    }
    
}
