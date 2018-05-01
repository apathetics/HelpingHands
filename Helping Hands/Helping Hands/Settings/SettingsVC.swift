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
import UserNotifications

class SettingsVC: UITableViewController, Themeable {
    
    let databaseRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    //ThemeableComponents
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var passwordLBL: UILabel!
    @IBOutlet weak var maxDistLBL: UILabel!
    @IBOutlet weak var newReviewLBL: UILabel!
    @IBOutlet weak var newSignUpLBL: UILabel!
    @IBOutlet weak var remindersSwitch: UISwitch!
    
    //Functional Components
    @IBOutlet weak var distLBL: UILabel!
    @IBOutlet weak var distSlider: UISlider!
    @IBOutlet weak var userNameLBL: UILabel!
    
    //Shared Notification Center
    let center = UNUserNotificationCenter.current()
    var allowNotifs: Bool!

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
        print("Settings:\nName=\(UserDefaults.standard.value(forKey: "user_name"))\nRadius=\(UserDefaults.standard.value(forKey: "max_radius"))\nReminder Notifications=\(UserDefaults.standard.bool(forKey: "reminders_notif"))")
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus != .authorized {
                // If user turned off notification permissions, set the switch to off
                UserDefaults.standard.set(false, forKey: "reminders_notif")
                self.allowNotifs = false
            } else {
                self.allowNotifs = true
            }
        })
        remindersSwitch.isOn = UserDefaults.standard.bool(forKey: "reminders_notif")
        
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
    
    @IBAction func setReminderNotifs(_ sender: UISwitch) {

        if !self.allowNotifs && sender.isOn {
            let alert = UIAlertController(title: "Notifications Disabled in Settings", message: "Please go to your settings app and enable notifications to turn your reminders back on.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            UserDefaults.standard.set(sender.isOn, forKey: "reminders_notif")
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
