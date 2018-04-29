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
        displayUserName()
        UserDefaults.standard.register(defaults: [String : Any]())
        
        if((UserDefaults.standard.value(forKey:"max_radius")) != nil) {
            distLBL.text = String(UserDefaults.standard.value(forKey:"max_radius") as! Int) + "mi."
            distSlider.value = UserDefaults.standard.value(forKey:"max_radius") as! Float
        }
        else {
            distSlider.value = 8
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayUserName()
        print("Settings:\nName=\(UserDefaults.standard.value(forKey: "user_name"))\nRadius=\(UserDefaults.standard.value(forKey: "max_radius"))")
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        distLBL.text = "\(Int(sender.value))mi."
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(Int(sender.value), forKey: "max_radius")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editName_Settings") {
            let destinationVC = segue.destination as! EditName_SettingsVC
            destinationVC.name = userNameLBL.text
        }
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
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(name, forKey: "user_name")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
