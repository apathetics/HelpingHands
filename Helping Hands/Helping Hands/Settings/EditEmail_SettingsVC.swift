//
//  EditEmail_SettingsVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/29/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class EditEmail_SettingsVC: UITableViewController, Themeable, UIPopoverPresentationControllerDelegate {
    
    //components
    
    @IBOutlet weak var checkmarkImg: UIImageView!
    @IBOutlet weak var emailImg: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var confirmLBL: UILabel!
    
    var user = FIRAuth.auth()?.currentUser
    
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")

    // methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        checkmarkImg.isHidden = true
        emailTF.text = user?.email
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            print("Confirm button pressed")
            // Empty fields, sent alert
            if emailTF.text == "" {
                let alert = UIAlertController(title: "Blank Field", message: "Please do not leave the field blank.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if user?.email == emailTF.text {
                // do nothing, email is the same
                return
            }
            
            user?.updateEmail(emailTF.text!) { error in
                if let error = error {
                    // Error handler
                    if let errCode = FIRAuthErrorCode(rawValue: error._code){
                        switch errCode {
                        case .errorCodeRequiresRecentLogin:
                            print("Requires recent login\n\n")
                            // Show reauth popover to get user credentials
                            self.showReauthPopover()
                            return
                        default:
                            // display alert
                            let alert = UIAlertController(title: "Invalid Email", message: "Please make sure the email you entered is valid.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.emailTF.text = ""
                            print(error)
                            return
                        }
                    }
                } else {
                    // Email update successful
                    print("Email change success!")
                    self.updateDatabase()
                    self.successAnimation(images: [self.checkmarkImg])
                }
            }
        }
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

    // Show reauthentication pop-up
    func showReauthPopover() {
        // Display popover view controller for re-authentication
        let reauthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReauthenticationVC") as! ReauthenticationVC
        reauthVC.preferredContentSize = CGSize(width: 300, height: 400)
        reauthVC.modalPresentationStyle = .popover
        
        let popover = reauthVC.popoverPresentationController
        popover?.delegate = self
        popover?.sourceView = self.view
        popover?.sourceRect  = CGRect(x: self.view.bounds.width*0.5, y: self.view.bounds.height*0.5, width: 0, height: 0)
        reauthVC.view.backgroundColor = UIColor(hex:"2b3445")
        
        self.present(reauthVC, animated: true, completion: nil)
    }
    
    // ensures that popover uses specified dimensions
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return .none
    }

    //Update database with new email if successful change
    func updateDatabase() {
        let userRef = databaseRef.child("users").child((user?.uid)!)
        userRef.updateChildValues(["email": emailTF.text])
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [self.view])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyIconStyle(icons: [emailImg])
        theme.applyTextFieldTextStyle(textFields: [emailTF])
        theme.applyTextFieldStyle(color: UIColor.white, textFields: [emailTF])
        theme.applyHeadlineStyle(labels: [confirmLBL])
    }
    
}
