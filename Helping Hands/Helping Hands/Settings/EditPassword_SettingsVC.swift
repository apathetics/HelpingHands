//
//  EditPassword_SettingsVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/29/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseAuth

class EditPassword_SettingsVC: UITableViewController, UIPopoverPresentationControllerDelegate, Themeable {
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPassTF: UITextField!
    @IBOutlet weak var passImg: UIImageView!
    @IBOutlet weak var confirmPassImg: UIImageView!
    @IBOutlet weak var confirmLBL: UILabel!
    
    var user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        passImg.isHidden = true
        confirmPassImg.isHidden = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1 && indexPath.row == 0) {
            print("Confirm pressed")
            if(passwordTF.text == "" || confirmPassTF.text == "") {
                let alert = UIAlertController(title: "Blank Fields", message: "Please do not leave any of the field blank.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                passwordTF.text = ""
                confirmPassTF.text = ""
                return
            }
            
            user?.updatePassword(passwordTF.text!) { error in
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .errorCodeRequiresRecentLogin:
                            self.showReauthPopover()
                            return
                        //case .errorCodeWeakPassword:
                        default:
                            let alert = UIAlertController(title: "Weak Password", message: "Please enter a stronger password and try again", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.passwordTF.text = ""
                            self.confirmPassTF.text = ""
                            return
                        }
                    }
                } else {
                    // Successful password change
                    print("successful password change")
                    self.successAnimation(images: [self.passImg, self.confirmPassImg])
                }
            }
        }
    }
    
    func showReauthPopover() {
        // Display popover view controller for re-authorization
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return .none
    }

    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [self.view])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyTextFieldTextStyle(textFields: [passwordTF, confirmPassTF])
        if(self.view.backgroundColor == UIColor.white) {
            theme.applyTextFieldStyle(color: UIColor.white, textFields: [passwordTF, confirmPassTF])
        } else {
            theme.applyTextFieldStyle(color: UIColor(hex:"1B212C"), textFields: [passwordTF, confirmPassTF])
        }
        theme.applyHeadlineStyle(labels: [confirmLBL])
    }
    
}
