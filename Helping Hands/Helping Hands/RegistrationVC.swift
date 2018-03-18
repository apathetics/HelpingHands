//
//  RegistrationVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class RegistrationVC: UIViewController {
    
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
    
    @IBOutlet weak var termsAgreementsCB: BEMCheckBox!
    @IBOutlet weak var over18CB: BEMCheckBox!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBAction func UploadImagePressed(_ sender: Any) {
    }
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        // Make sure none of the fields are empty
        // (image is optional, placeholder will be used if none specified)
        if firstNameTF.text == "" || lastNameTF.text == "" || emailTF.text! == "" || passwordTF.text! == "" || confirmPasswordTF.text == "" {
            let alert = UIAlertController(title: "Empty Fields!",
                                          message: "Make sure all the fields are completed",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Make sure both passwords match
        if passwordTF.text != confirmPasswordTF.text {
            passwordTF.text = ""
            confirmPasswordTF.text = ""
            return
        }
        
        if let email = emailTF.text, let pass = passwordTF.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { user, error in
                if let firebaseError = error {
                    print(firebaseError.localizedDescription)
                    return
                }
                print("Registration Success!")
                guard let uid = user?.uid else {
                    return
                }
                let userReference = self.databaseRef.child("users").child(uid)
                let values = ["firstName": self.firstNameTF.text!, "lastName": self.lastNameTF.text!, "email": self.emailTF.text!, "photo": ""]
                
                userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                })
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

