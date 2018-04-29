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
    
    var user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        var fullNameArr = name.components(separatedBy: " ")
        firstNameTF.text = fullNameArr[0]
        lastNameTF.text = fullNameArr.count > 1 ? fullNameArr[1] : ""
        print("Name Array: " , fullNameArr , "\n")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if(name == "\(firstNameTF.text) \(lastNameTF.text)") {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyle.default
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1 && indexPath.row == 0) {
            print("Confirm button clicked")
            if (firstNameTF.text == "" || lastNameTF.text == "") {
                let alert = UIAlertController(title: "Blank Fields", message: "Please do not leave any of the fields blank.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            // None of the fields are blank, successful name change
            if (name != "\(firstNameTF.text) \(lastNameTF.text)") {
                user?.profileChangeRequest().displayName = firstNameTF.text
                updateDatabase()
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
