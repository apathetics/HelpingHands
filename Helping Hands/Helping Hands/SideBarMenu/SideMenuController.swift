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
    
    var user: FIRUser!
    let userRef = FIRDatabase.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Display profile image as a cirle
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileTapGesture))
        profileImage.addGestureRecognizer(profileTap)
        profileImage.isUserInteractionEnabled = true
        populateSideMenu()
    }
    
    // Dummy for connecting to PROFILE screen
    @objc func profileTapGesture() {
        print("Image Tapped")
        self.performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showProfile") {
            let u:User = grabProfile()
            let userVC:UserViewController = segue.destination as! UserViewController
            userVC.user = u
        }
        if(segue.identifier == "showContactUs") {
            
        }
    }
    
    func grabProfile() -> User {
        let user:User = User()
        user.userFirstName = "Profiley"
        user.userLastName = "Profiler"
        user.userEmail = "hmu@yahoo.com"
        user.userBio = "This is a profile fam"
        user.userJobsCompleted = 4
        user.userLocationRadius = 0.0
        user.userNumJobsPosted = 10
        
        // Change the ones below
        return user
    }
    
    @IBAction func settingsButtonClicked(_ sender: Any) {
        print("Clicked settings")
    }
    
    @IBAction func contactUsButtonClicked(_ sender: Any) {
        print("Clicked contact us")
        self.performSegue(withIdentifier: "showContactUs", sender: self)
    }
    
    @IBAction func nightModeButtonClicked(_ sender: Any) {
        print("Clicked night mode")
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
