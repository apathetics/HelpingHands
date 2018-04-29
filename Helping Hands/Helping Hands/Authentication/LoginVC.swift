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

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
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
                        //display alert
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
                    if(UserDefaults.standard.value(forKey: "max_radius") == nil) {
                        UserDefaults.standard.set(8, forKey: "max_radius")
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // If user hasn't logged out
        if (FIRAuth.auth()?.currentUser != nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let SWRController: SWRevealViewController = storyboard.instantiateViewController(withIdentifier: "SWRController") as! SWRevealViewController
            appDelegate.window?.rootViewController = SWRController
            if(UserDefaults.standard.value(forKey: "max_radius") == nil) {
                UserDefaults.standard.set(8, forKey: "max_radius")
            }
//            if(UserDefaults.standard.value(forKey: "user_name") == nil) {
//                UserDefaults.standard.set(FIRAuth.auth()?.currentUser?.uid., forKey: "user_name")
//            }


        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

