//
//  SideMenuController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/20/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class SideMenuController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userNumJobsCompleted: UILabel!
    @IBOutlet weak var userNumJobsPosted: UILabel!
    @IBOutlet weak var userMoneyEarned: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(tapGesture1))
        profileImage.addGestureRecognizer(profileTap)
        profileImage.isUserInteractionEnabled = true
    }
    
    // Dummy for connecting to PROFILE screen
    @objc func tapGesture1() {
        print("Image Tapped")
    }
    
    @IBAction func settingsButtonClicked(_ sender: Any) {
        print("Clicked settings")
    }
    
    @IBAction func contactUsButtonClicked(_ sender: Any) {
        print("Clicked contact us")
    }
    
    @IBAction func nightModeButtonClicked(_ sender: Any) {
        print("Clicked night mode")
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
