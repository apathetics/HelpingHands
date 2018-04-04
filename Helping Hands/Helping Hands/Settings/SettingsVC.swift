//
//  SettingsVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/4/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SettingsVC: UITableViewController, Themeable {
    
    //ThemeableComponents
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var passwordLBL: UILabel!
    @IBOutlet weak var maxDistLBL: UILabel!
    @IBOutlet weak var newReviewLBL: UILabel!
    @IBOutlet weak var newSignUpLBL: UILabel!

    //Functional Components
    @IBOutlet weak var distLBL: UILabel!
    @IBOutlet weak var distSlider: UISlider!
    @IBOutlet weak var userNameLBL: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLBL.text = getUserName()
        ThemeService.shared.addThemeable(themable: self)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
    }
    
    func getUserName() -> String {
        var name = ""
        let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
        let databaseRef = FIRDatabase.database().reference().child("users").child(userID)
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            name = "\(value?["firstName"] as? String ?? "") \(value?["lastName"] as? String ?? "")"
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }

        return name
    }
}
