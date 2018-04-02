//
//  SideMenuController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/20/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorageUI

class SideMenuController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userNumJobsCompleted: UILabel!
    @IBOutlet weak var userNumJobsPosted: UILabel!
    @IBOutlet weak var userMoneyEarned: UILabel!
    
    @IBOutlet weak var themeButton: UIButton!
    var selectedTheme: UIImage = UIImage(named: "nightModeIcon")!
    var otherTheme: UIImage = UIImage(named: "dayModeIcon")!

    
    var user: User!
    let userRef = FIRDatabase.database().reference().child("users")
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Display profile image as a cirle
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileTapGesture))
        profileImage.addGestureRecognizer(profileTap)
        profileImage.isUserInteractionEnabled = true
        
        retrieveUser()
        populateSideMenu()
    }
    // Dummy for connecting to PROFILE screen
    @objc func profileTapGesture() {
        print("Image Tapped")
        self.performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showProfile") {
            let userVC:UserViewController = segue.destination as! UserViewController
            userVC.user = self.user
        }
        if(segue.identifier == "showContactUs") {
            
        }
    }
    
    func grabProfile() -> User {
        let user:User = User()
        user.userFirstName = "FirstName"
        user.userLastName = "LastName"
        user.userEmail = "user@email.com"
        user.userBio = "This is a user bio. Forgive the dummy! :)"
        user.userJobsCompleted = 4
        user.userLocationRadius = 0.0
        user.userNumJobsPosted = 10
        user.userPhoto = UIImage(named: "meeting")
        // Change the ones below
        return user
    }
    
    // FIREBASE RETRIEVAL
    func retrieveUser() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let jobRef = databaseRef.child("users").child(userId)
        
        jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            // retrieve jobs and append to job list after creation
            let userObject = snapshot.value as! [String: AnyObject]
            let user:User = User()
            
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
    
    @IBAction func themeButtonClicked(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.themeButton.alpha = 0.0
        }, completion: { (bool) in
            // change image to image B
            self.themeButton.setImage(self.otherTheme, for: .normal)
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                self.themeButton.alpha = 1.0
            }, completion: { (b) in
                // Swap image A and image B
                swap(&self.selectedTheme, &self.otherTheme)
            })
        })
        
        print("Clicked theme button")
    }
    
    @IBAction func settingsButtonClicked(_ sender: Any) {
        print("Clicked settings")
    }
    
    @IBAction func contactUsButtonClicked(_ sender: Any) {
        print("Clicked contact us")
        self.performSegue(withIdentifier: "showContactUs", sender: self)
    }
    
    // TEMPORARY PLACEMENT TO SHOW SCREENS
    @IBAction func confirmHiredButton(_ sender: Any) {
        self.performSegue(withIdentifier: "showConfirmationHired", sender: self)
    }
    
    @IBAction func confirmHireeButton(_ sender: Any) {
        self.performSegue(withIdentifier: "showConfirmationHiree", sender: self)
    }
    
    @IBAction func paymentHireeButton(_ sender: Any) {
        self.performSegue(withIdentifier: "showPaymentHiree", sender: self)
    }
    
    @IBAction func paymentHiredButton(_ sender: Any) {
        self.performSegue(withIdentifier: "showPaymentHired", sender: self)
    }
    func populateSideMenu() {

        if let userID:String = (FIRAuth.auth()?.currentUser?.uid) {
            userRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user values
                let value = snapshot.value as? NSDictionary
                let fName = value?["firstName"] as? String ?? ""
                let lName = value?["lastName"] as? String ?? ""
                let jobsDone = String(value?["jobsCompleted"] as! Int64)
                let jobsPosted = String(value?["jobsPosted"] as! Int64)
                let moneyEarned = String(value?["moneyEarned"] as! Int64)
                // Placeholder image
                let placeholderImage = UIImage(named: "profilePlaceholderImg.png")
                // Load the image using SDWebImage
                self.profileImage.sd_setImage(with: URL(string: value?["photoUrl"] as! String), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                })
                // Populate sidebar
                self.userNameLabel.text = "\(fName) \(lName)"
                self.userNumJobsCompleted.text = jobsDone
                self.userNumJobsPosted.text = jobsPosted
                self.userMoneyEarned.text = "$ \(moneyEarned)"
            }) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("User ID is nil")
        }
    }
    
    // Blurring option works but there's a weird line at the top that doesn't fully conform.
    //    override func viewWillAppear(_ animated: Bool) {
    //
    //        self.revealViewController().frontViewController.view.alpha = 0.5
    //    }
    //
    //    override func viewWillDisappear(_ animated: Bool) {
    //
    //        self.revealViewController().frontViewController.view.alpha = 1
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
