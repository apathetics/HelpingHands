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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        var fullNameArr = name.components(separatedBy: " ")
        firstNameTF.text = fullNameArr[0]
        lastNameTF.text = fullNameArr.count > 1 ? fullNameArr[1] : ""
        firstNameImg.isHidden = true
        lastNameImg.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var fullName: String = "\(firstNameTF.text!) \(lastNameTF.text!)" as String
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1 && indexPath.row == 0) {
            var fullName: String = "\(firstNameTF.text!) \(lastNameTF.text!)" as String

            if (firstNameTF.text == "" || lastNameTF.text == "") {
                let alert = UIAlertController(title: "Blank Fields", message: "Please do not leave any of the fields blank.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            // None of the fields are blank, successful name change
            if (name != fullName) {
                user?.profileChangeRequest().displayName = firstNameTF.text
                updateDatabase()
                name = fullName
                //animate check mark to indicate success
                firstNameImg.isHidden = false
                lastNameImg.isHidden = false
                self.firstNameImg.alpha = 0
                self.lastNameImg.alpha = 0
                UIView.animate(withDuration: 1.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.firstNameImg.alpha = 1
                    self.lastNameImg.alpha = 1
                }, completion: { (bool) in
                    UIView.animate(withDuration: 0.3, animations: {
                        self.firstNameImg.alpha = 0
                        self.lastNameImg.alpha = 0
                    }, completion: { (b) in
                        self.firstNameImg.isHidden = true
                        self.lastNameImg.isHidden = true

                    })
                })
                
            } else {
                print("No changes were made")
                let alert = UIAlertController(title: "No Changes Made", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func updateDatabase() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
        let userRef = databaseRef.child("users").child((user?.uid)!)
        userRef.updateChildValues(["firstName": firstNameTF.text, "lastName": lastNameTF.text])
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
