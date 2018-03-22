//
//  UserViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorageUI

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
    
    let userRef = FIRDatabase.database().reference().child("users")
    
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
//        userPhoto.image = user.userPhoto
//        userName.text = (user.userFirstName)! + " " + (user?.userLastName)!
//        userEmail.text = user.userEmail
//        userDescription.text = user.userBio
//        // Change the ones below
//        userRating.text = String(describing: user.userNumJobsPosted!)
//        userLocation.text = String(describing: user.userLocationRadius!)
//        userDistance.text = String(describing: user.userJobsCompleted!)
        
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
    
    func populateProfile() {
        
        if let userID:String = (FIRAuth.auth()?.currentUser?.uid) {
            userRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user values
                let value = snapshot.value as? NSDictionary
                let fName = value?["firstName"] as? String ?? ""
                let lName = value?["lastName"] as? String ?? ""
                let email = value?["email"] as? String ?? ""
                let bio = value?["bio"] as? String ?? ""
                let rating = value?["rating"] as? String ?? ""
//                let jobsDone = String(value?["jobsCompleted"] as! Int64)
//                let jobsPosted = String(value?["jobsPosted"] as! Int64)
//                let moneyEarned = String(value?["moneyEarned"] as! Int64)
                // Placeholder image
                let placeholderImage = UIImage(named: "meeting")
                // Load the image using SDWebImage
                self.userPhoto.sd_setImage(with: URL(string: value?["photoUrl"] as! String), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                })
                // Populate Profile Info
                self.userName.text = fName + " " + lName
                self.userEmail.text = email
                self.userDescription.text = bio
                self.userRating.text = String(rating)
                self.userLocation.text = "RADIUS PLACEHOLDER"
                self.userDistance.text = "0 DISTANCE PLACEHOLDER"
                
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("User ID is nil")
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
