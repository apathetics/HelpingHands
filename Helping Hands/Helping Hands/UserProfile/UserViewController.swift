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
    
//    let userRef = FIRDatabase.database().reference().child("users")
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
    
    var imgChosen = false
    var user:User!
    var userIndexPath:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // do verifcation if user = currently logged in
//        if(user.userID != 0) {
//            self.navigationItem.rightBarButtonItem =  nil;
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveUser()
    
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        self.userPhoto.sd_setImage(with: URL(string: self.user.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })

        
        userName.text = (user.userFirstName)! + " " + (user?.userLastName)!
        userEmail.text = user.userEmail
        userDescription.text = user.userBio
        
        // Change the ones below
        userRating.text = String(describing: user.userRating!)
        userLocation.text = String(describing: user.userLocationRadius!)
        userDistance.text = String(describing: user.userDistance!)
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
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func populateProfile() {
        
//        if let userID:String = (FIRAuth.auth()?.currentUser?.uid) {
//            userRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
//                // Get user values
//                let value = snapshot.value as? NSDictionary
//                let fName = value?["firstName"] as? String ?? ""
//                let lName = value?["lastName"] as? String ?? ""
//                let email = value?["email"] as? String ?? ""
//                let bio = value?["bio"] as? String ?? ""
//                let rating = value?["rating"] as? String ?? ""
////                let jobsDone = String(value?["jobsCompleted"] as! Int64)
////                let jobsPosted = String(value?["jobsPosted"] as! Int64)
////                let moneyEarned = String(value?["moneyEarned"] as! Int64)
//                // Placeholder image
//                let placeholderImage = UIImage(named: "meeting")
//                // Load the image using SDWebImage
//                self.userPhoto.sd_setImage(with: URL(string: value?["photoUrl"] as! String), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
//                })
                // Populate Profile Info
                self.userName.text = self.user.userFirstName + " " + self.user.userLastName
                self.userEmail.text = self.user.userEmail
                self.userDescription.text = self.user.userBio
                self.userRating.text = "TEMPORARY RATING"
                self.userLocation.text = "RADIUS PLACEHOLDER"
                self.userDistance.text = "0 DISTANCE PLACEHOLDER"
    
    }
    
    // FIREBASE RETRIEVAL
    func retrieveUser() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let userRef = databaseRef.child("users").child(userId)
        
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // retrieve jobs and append to job list after creation
            let userObject = snapshot.value as! [String: AnyObject]
            let user = User()
            
            user.userFirstName = userObject["firstName"] as! String
            user.userLastName = userObject["lastName"] as! String
            user.userEmail = userObject["email"] as! String
            user.userJobsCompleted = userObject["jobsCompleted"] as! Int
            user.userNumJobsPosted = userObject["jobsPosted"] as! Int
            user.userMoneyEarned = userObject["moneyEarned"] as! Double
            user.userPhotoAsString = userObject["photoUrl"] as! String
            
            //TODO: SETTINGS NOT IN DATABASE YET
            user.userLocationRadius = 1
            user.userDistance = 1
            user.userRating = 5
            
            user.userID = self.userId
            
            self.user = user
        })
    }
    
}
