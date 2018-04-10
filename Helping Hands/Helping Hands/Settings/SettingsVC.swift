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
    
    let databaseRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    
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
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayUserName()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 3 && indexPath.row == 0) {
            print("Log out button clicked")
            let alert = UIAlertController(title: userNameLBL.text, message: "Are you sure you want to log out of Helping Hands?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                tableView.deselectRow(at: indexPath, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Log out", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Log out Logic here")
                do {
                    try FIRAuth.auth()?.signOut()
                } catch let logoutError {
                    print(logoutError)
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateInitialViewController()
                self.present(loginVC!, animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)


        }
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyBodyTextStyle(labels: [nameLBL, emailLBL, passwordLBL, maxDistLBL, newReviewLBL, newSignUpLBL, userNameLBL])
    }
    
    func displayUserName() {
        var name = ""
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            name = "\(value?["firstName"] as? String ?? "") \(value?["lastName"] as? String ?? "")"
            self.userNameLBL.text = name
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
