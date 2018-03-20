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
                if let firebaseError = error {
                    print(firebaseError.localizedDescription)
                    return
                }
                print("Login Success!")
                // Take user to the Home Page
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let SWRController: SWRevealViewController = storyboard.instantiateViewController(withIdentifier: "SWRController") as! SWRevealViewController
                appDelegate.window?.rootViewController = SWRController
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

