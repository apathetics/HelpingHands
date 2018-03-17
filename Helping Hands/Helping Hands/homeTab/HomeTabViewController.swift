//
//  HomeTabViewController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 2/28/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class HomeTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var jobToAdd:Job?
    var jobs = [Job]()
    
    @IBOutlet weak var table: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:JobTableViewCell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobTableViewCell
        
        let row = indexPath.row
        let j:Job = jobs[row]
        
        cell.jobTitleLbl.text = j.jobTitle
        cell.jobDescriptionLbl.text = j.jobDescription
        cell.distanceLbl.text = String(j.distance!) + " mi"
        let ftmPayment = "$" + (j.payment.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(j.payment)) : String(j.payment))
        cell.paymentLbl.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        cell.jobImg.image = j.image
        
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
        let addJobVC:AddJobViewController = segue.destination as! AddJobViewController
        addJobVC.masterView = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (jobToAdd != nil) {
            jobs.insert(jobToAdd!, at: 0)
            jobToAdd = nil
            table.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            table.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .none)
        }
        
    }

}

