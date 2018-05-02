//
//  LoginVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseAuth

class LoginVC: UIViewController {

    // Components
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    // Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() // dismiss keyboard
        
        // If user hasn't logged out -> Auto Login
        if (FIRAuth.auth()?.currentUser != nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let SWRController: SWRevealViewController = storyboard.instantiateViewController(withIdentifier: "SWRController") as! SWRevealViewController
            appDelegate.window?.rootViewController = SWRController
            // Set default max radius
            if(UserDefaults.standard.value(forKey: "max_radius") == nil) {
                UserDefaults.standard.set(8, forKey: "max_radius")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTF.text, let pass = passwordTF.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                if error != nil {
                    // error handler
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        var title: String = ""
                        var message: String = ""
                        var log: String = ""
                        
                        switch errCode {
                            case .errorCodeWrongPassword:
                                title = "Incorrect Password"
                                message = "The password you entered is incorrect. Please try again."
                                log = "Incorrect Password Alert Displayed"
                            default:
                                title = "Incorrect Credentials"
                                message = "The credentials you entered are incorrect. Please try again."
                                log = "Other error Alert Displayed"
                        }
                        //display alert with message
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            NSLog(log)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    print("Login Success!")
                    // Take user to the Home Page
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let SWRController: SWRevealViewController = storyboard.instantiateViewController(withIdentifier: "SWRController") as! SWRevealViewController
                    appDelegate.window?.rootViewController = SWRController
                    // Set default max radius
                    if(UserDefaults.standard.value(forKey: "max_radius") == nil) {
                        UserDefaults.standard.set(8, forKey: "max_radius")
                    }
                }
            })
        }
    }
}
