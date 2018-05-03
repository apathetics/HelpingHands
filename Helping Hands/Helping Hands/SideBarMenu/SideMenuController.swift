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

class SideMenuController: UIViewController, Themeable {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNumJobsCompleted: UILabel!
    @IBOutlet weak var userNumJobsPosted: UILabel!
    @IBOutlet weak var userMoneyEarned: UILabel!
    @IBOutlet weak var jobsCompletedLBL: UILabel!
    @IBOutlet weak var jobsPostedLBL: UILabel!
    @IBOutlet weak var moneyEarnedLBL: UILabel!
    @IBOutlet weak var SettingsBTN: UIButton!
    @IBOutlet weak var ContactBTN: UIButton!
    @IBOutlet weak var themeButton: UIButton!
    
    var selectedThemeIcon: UIImage = UIImage(named: "nightModeIcon")!
    var otherThemeIcon: UIImage = UIImage(named: "dayModeIcon")!
    var selectedTheme: Theme = DarkTheme()
    var otherTheme: Theme = DefaultTheme()
    var selectedStatusBarColor: UIStatusBarStyle = UIStatusBarStyle.lightContent
    var otherStatusBarColor: UIStatusBarStyle = UIStatusBarStyle.default

    var user: User!
    
    let userRef = FIRDatabase.database().reference().child("users")
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    let currentUser = FIRAuth.auth()?.currentUser
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Theme
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // Display profile image as a cirle
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        //Open user profile page when clicking on image
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileTapGesture))
        profileImage.addGestureRecognizer(profileTap)
        profileImage.isUserInteractionEnabled = true
        
        // Retrieve the user currently logged in.
        retrieveUser()
        
        // Update side menu with correct label info.
        populateSideMenu()
    }
    
    // On tap of profile picture, we segue to profile.
    @objc func profileTapGesture() {
        print("Image Tapped")
        self.performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    // Send the user info to the profile segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showProfile") {
            let destVC: UINavigationController = segue.destination as! UINavigationController
            let userVC:UserViewController = destVC.topViewController as! UserViewController
            userVC.user = self.user
        }
    }
    
    // FIREBASE RETRIEVAL
    func retrieveUser() {
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
            
            if(userObject["bio"] as? String == nil || userObject["bio"] as! String == "") {
                user.userBio = "Description..."
            }
            else {
                user.userBio = userObject["bio"] as! String
            }
            // get radius from settings
            user.userLocationRadius = UserDefaults.standard.value(forKey: "max_radius") as! Double
            
            //TODO: SETTINGS NOT IN DATABASE YET
            user.userDistance = 1
            user.userRating = 5
            
            user.userID = self.userId
            
            self.user = user
        })
        
    }
    
    // Change theme to color schemes
    @IBAction func themeButtonClicked(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.themeButton.alpha = 0.0
        }, completion: { (bool) in
            // change image to image B
            self.themeButton.setImage(self.otherThemeIcon, for: .normal)
            ThemeService.shared.theme = self.selectedTheme
            UIApplication.shared.statusBarStyle = self.selectedStatusBarColor
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                self.themeButton.alpha = 1.0
            }, completion: { (b) in
                // Swap image A and image B
                swap(&self.selectedThemeIcon, &self.otherThemeIcon)
                swap(&self.selectedTheme, &self.otherTheme)
                swap(&self.selectedStatusBarColor, &self.otherStatusBarColor)
            })
        })
        
        print("Clicked theme button")
    }
    
    // How are we seguing to settings? Huh?
    @IBAction func settingsButtonClicked(_ sender: Any) {
        print("Clicked settings")
    }
    
    @IBAction func contactUsButtonClicked(_ sender: Any) {
        print("Clicked contact us")
        self.performSegue(withIdentifier: "showContactUs", sender: self)
    }
    
    // Function to populate the side bar
    func populateSideMenu() {

        if self.userId != nil {
            userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user values
                let value = snapshot.value as? NSDictionary
                let fName = value?["firstName"] as? String ?? ""
                let lName = value?["lastName"] as? String ?? ""
                let jobsDone = String(value?["jobsCompleted"] as! Int)
                let jobsPosted = String(value?["jobsPosted"] as! Int)
                let moneyEarned = String(value?["moneyEarned"] as! Double)
                
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
            print("UserId is nil")
        }
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyBodyTextStyle(labels: [userNumJobsPosted, userNumJobsCompleted, userMoneyEarned, jobsPostedLBL, moneyEarnedLBL, jobsCompletedLBL])
        theme.applyHeadlineStyle(labels: [userNameLabel])
        theme.applyButtonTextStyle(buttons: [ContactBTN, SettingsBTN])
    }
    
}
