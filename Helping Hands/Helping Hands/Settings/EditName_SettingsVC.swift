//
//  EditName_SettingsVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/29/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class EditName_SettingsVC: UITableViewController, Themeable {
    
    //themeable components
    @IBOutlet weak var fNameLBL: UILabel!
    @IBOutlet weak var lNameLBL: UILabel!
    @IBOutlet weak var confirmLBL: UILabel!
    
    //functional components
    var name: String!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameImg: UIImageView!
    @IBOutlet weak var lastNameImg: UIImageView!
    
    var user = FIRAuth.auth()?.currentUser
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")

    // methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        // split name string into first and last name
        var fullNameArr = name.components(separatedBy: " ")
        firstNameTF.text = fullNameArr[0]
        lastNameTF.text = fullNameArr.count > 1 ? fullNameArr[1] : ""
        // hide checkmarks
        firstNameImg.isHidden = true
        lastNameImg.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // A small checkmark animation indicating a successful email change
    func successAnimation(images: [UIImageView]) {
        for img in images {
            img.isHidden = false
            img.alpha = 0
            UIView.animate(withDuration: 1.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                img.alpha = 1
            }) { (bool) in
                UIView.animate(withDuration: 0.3, animations: {
                    img.alpha = 0
                }, completion: { (b) in
                    img.isHidden = true
                })
            }
        }
    }
    
    // Update database with new user name
    func updateDatabase() {
        let userRef = databaseRef.child("users").child((user?.uid)!)
        userRef.updateChildValues(["firstName": firstNameTF.text, "lastName": lastNameTF.text])
    }

    // tableview functions
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var fullName: String = "\(firstNameTF.text!) \(lastNameTF.text!)" as String
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Confirm button selected
        if(indexPath.section == 1 && indexPath.row == 0) {
            var fullName: String = "\(firstNameTF.text!) \(lastNameTF.text!)" as String
            //empty text fields
            if (firstNameTF.text == "" || lastNameTF.text == "") {
                //display alert
                let alert = UIAlertController(title: "Blank Fields", message: "Please do not leave any of the fields blank.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if (name != fullName) {
                //successful name change
                user?.profileChangeRequest().displayName = firstNameTF.text
                updateDatabase()
                name = fullName
                //animate check mark to indicate success
                successAnimation(images: [self.firstNameImg, self.lastNameImg])
                
            } else {
                // No changes made, display alert
                print("No changes were made")
                let alert = UIAlertController(title: "No Changes Made", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func applyTheme(theme: Theme) {
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyBodyTextStyle(labels: [fNameLBL, lNameLBL])
        theme.applyTextFieldTextStyle(textFields: [firstNameTF, lastNameTF])
        theme.applyTextFieldStyle(color: UIColor.clear, textFields: [firstNameTF, lastNameTF])
        theme.applyHeadlineStyle(labels: [confirmLBL])
        theme.applyBackgroundColor(views: [self.view])
    }
}
