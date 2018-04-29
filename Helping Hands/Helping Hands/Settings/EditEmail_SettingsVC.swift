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

class EditEmail_SettingsVC: UITableViewController, Themeable {
    
    @IBOutlet weak var checkmarkImg: UIImageView!
    @IBOutlet weak var emailImg: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var confirmLBL: UILabel!
    
    var user = FIRAuth.auth()?.currentUser
    
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
            //print("update to this \(emailTF.text!)\n\n\n")
            user?.updateEmail(emailTF.text!) { error in
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code){
                        switch errCode {
                        case .errorCodeRequiresRecentLogin:
                            print("Requires recent login\n\n")
                            let reauthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReauthenticationVC") as! ReauthenticationVC
                            reauthVC.modalPresentationStyle = UIModalPresentationStyle.currentContext
                            self.present(reauthVC, animated: true, completion: {
//                                if (reauthVC.success) {
//
//                                } else {
//
//                                }
                            })
                            return
                        default:
                            let alert = UIAlertController(title: "Invalid Email", message: "Please make sure the email you entered is valid.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.emailTF.text = ""
                            print(error)
                            return
                        }
                    }
                } else {
                    // Email updated.
                    print("Email change success!")
                    self.updateDatabase()
                    self.checkmarkImg.isHidden = false
                    self.checkmarkImg.alpha = 0
                    UIView.animate(withDuration: 1.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        self.checkmarkImg.alpha = 1
                    }) { (bool) in
                        UIView.animate(withDuration: 0.3, animations: {
                            self.checkmarkImg.alpha = 0
                        }, completion: { (b) in
                            self.checkmarkImg.isHidden = true
                        })
                    }

                }
            }

//            user?.updateEmail(emailTF.text!, completion: { (error) in
//                let alert = UIAlertController(title: "Invalid Email", message: "Please make sure the email you entered is valid.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                self.emailTF.text = ""
//
//                return
//            })
//            print("Email change success!")
//            updateDatabase()
//            checkmarkImg.isHidden = false
//            checkmarkImg.alpha = 0
//            UIView.animate(withDuration: 1.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
//                self.checkmarkImg.alpha = 1
//            }) { (bool) in
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.checkmarkImg.alpha = 0
//                }, completion: { (b) in
//                    self.checkmarkImg.isHidden = true
//                })
//            }
            
        }
    }
    
    func updateDatabase() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
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
    }
    
}
