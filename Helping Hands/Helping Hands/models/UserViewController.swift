//
//  UserViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class UserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userDistance: UILabel!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var jobBar: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var imgChosen = false
    // TODO - Pass using database
    var masterView:JobViewController?
    var clearCore: Bool = false
    var user:User!
    // TODO - Pass using database
    var userIndexPath:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(user.userID != 0) {
            self.navigationItem.rightBarButtonItem =  nil;
        }
        userPhoto.image = user.userPhoto
        userName.text = (user.userFirstName)! + " " + (user?.userLastName)!
        userEmail.text = user.userEmail
        userDescription.text = user.userBio
        // Change the ones below
        userRating.text = String(describing: user.userNumJobsPosted!)
        userLocation.text = String(describing: user.userLocationRadius!)
        userDistance.text = String(describing: user.userJobsCompleted!)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
         if clearCore {
         clearCoreuser()
         }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        userPhoto.image = user.userPhoto
        userName.text = (user.userFirstName)! + " " + (user?.userLastName)!
        userEmail.text = user.userEmail
        userDescription.text = user.userBio
        // Change the ones below
        userRating.text = String(describing: user.userNumJobsPosted!)
        userLocation.text = String(describing: user.userLocationRadius!)
        userDistance.text = String(describing: user.userJobsCompleted!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showEditUser")
        {
            let editorVC:EditUserViewController = segue.destination as! EditUserViewController
            editorVC.masterView = self
            print(user.userFirstName)
            editorVC.user = user
        }
    }
    
    /*
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return inquiries.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell:userTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! userTableViewCell
     
     let row = indexPath.row
     let j:NSManagedObject = inquiries[row]
     
     cell.userTitleLbl.text = j.value(forKey: "userTitle") as? String
     cell.userDescriptionLbl.text = j.value(forKey: "userDescription") as? String
     cell.distanceLbl.text = String(j.value(forKey: "userDistance") as! Double) + " mi"
     let ftmPayment = "$" + ((j.value(forKey: "userPayment") as! Double).truncatingRemainder(dividingBy: 1) == 0 ? String(j.value(forKey: "userPayment") as! Int64) : String(j.value(forKey: "userPayment") as! Double))
     print("PAYMENT IS:", ftmPayment)
     cell.paymentLbl.text = j.value(forKey: "userIsHourlyPaid") as! Bool == true ? ftmPayment + "/hr" : ftmPayment
     cell.userImg.image = UIImage(data: j.value(forKey: "userImage") as! Data)
     
     return cell
     }*/
}
