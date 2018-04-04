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

class UserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, Themeable {

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
        ThemeService.shared.addThemeable(themable: self)
        // do verifcation if user = currently logged in
//        if(user.userID != 0) {
//            self.navigationItem.rightBarButtonItem =  nil;
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveUser()
    
        // check for user permissions to edit
        let userRef = databaseRef.child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.ref.key == self.userId {
                print("SNAPSHOT KEY", snapshot.ref.key, self.userId)
                self.navigationItem.rightBarButtonItem?.title =  "Edit";
            }
        })
        
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
    
    @IBAction func onEditButtonClick(_ sender: Any) {
        self.performSegue(withIdentifier: "showEditUser", sender: self)
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
            user.userBio = userObject["bio"] as! String
            
            //TODO: SETTINGS NOT IN DATABASE YET
            user.userLocationRadius = 1
            user.userDistance = 1
            user.userRating = 5
            
            user.userID = self.userId
            
            self.user = user
        })
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyTableViewBackgroundColor(tableView: table)
        theme.applyHeadlineStyle(labels: [userName])
        theme.applyBodyTextStyle(labels: [userEmail, userRating, userLocation, userDistance])
        theme.applySegmentedControlStyle(controls: [jobBar])
    }
    
}
