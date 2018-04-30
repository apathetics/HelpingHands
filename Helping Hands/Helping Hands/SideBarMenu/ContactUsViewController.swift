//
//  ContactUsViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/30/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAuth

class ContactUsViewController: UITableViewController, MFMailComposeViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate, Themeable {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var msgTV: UITextView!
    
    var user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ThemeService.shared.addThemeable(themable: self)
        // Do any additional setup after loading the view.
        msgTV.delegate = self
        nameTF.delegate = self
        emailTF.delegate = self
        subjectTF.delegate = self
        
        //Display user name and email based on account
        nameTF.text = user?.displayName
        emailTF.text = user?.email
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        let mailVC = MFMailComposeViewController()
        if(!MFMailComposeViewController.canSendMail()) {
            print("can't send any mail!!!!!")
            return
        }

        mailVC.mailComposeDelegate = self
        mailVC.setSubject(subjectTF.text!)
        
        let email = emailTF.text?.lowercased()
        let finalEmail = email?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        let mailContent = "Name: \(nameTF.text!)\n\nSubject: \(subjectTF.text!)\n\nEmail: \(finalEmail)\n\nMessage: \(msgTV.text!)"
        
        mailVC.setMessageBody(msgTV.text!, isHTML: false)
        
        mailVC.setToRecipients(["manasa.tipparam@gmail.com", "bryanbernal97@gmail.com", "kafleyozone@gmail.com"])
        
        self.present(mailVC, animated: true) {
            self.nameTF.text = ""
            self.emailTF.text = ""
            self.subjectTF.text = ""
            self.msgTV.text = ""
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [self.view])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTF.resignFirstResponder()
        emailTF.resignFirstResponder()
        subjectTF.resignFirstResponder()
    
        return true
    }
}
