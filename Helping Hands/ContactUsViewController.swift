//
//  ContactUsViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/30/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var subjectFld: UITextField!
    @IBOutlet weak var body: UITextView!
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let subjectText = subjectFld.text!
        let bodyText = body.text!
        
        let mailViewController:MFMailComposeViewController = MFMailComposeViewController()
            
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject(subjectText)
        mailViewController.setMessageBody(bodyText, isHTML: false)
        mailViewController.setToRecipients(["kafleyozone@gmail.com"])
        
        return mailViewController
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Error Sending Mail", message: "Please try again after properly setting up your email account on this device.", preferredStyle: UIAlertControllerStyle.alert)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        let mailComposeVC = configuredMailComposeViewController()
        self.dismiss(animated: true, completion: nil)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
