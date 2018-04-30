//
//  ReauthenticationVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/29/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseAuth

class ReauthenticationVC: UIViewController {
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var badPassLBL: UILabel!
    
    var user = FIRAuth.auth()?.currentUser
    var success: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
        badPassLBL.isHidden = true
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        var credential = FIREmailPasswordAuthProvider.credential(withEmail: (user?.email)!, password: passwordTF.text!)
        user?.reauthenticate(with: credential, completion: { (error) in
            if error == nil {
                self.success = true
                self.dismiss(animated: true, completion: nil)
                return
            } else {
                self.success = false
                self.badPassLBL.isHidden = false
                let alert = UIAlertController(title: "Incorrect Password", message: "Please check that the password you entered is correct.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.passwordTF.text = ""
            }
        })
    }
    
    
}
