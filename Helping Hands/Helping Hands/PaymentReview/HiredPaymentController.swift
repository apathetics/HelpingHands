//
//  hiredPaymentController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorageUI

class HiredPaymentController: UIViewController {
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var payerLabel: UILabel!
    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var ratingStars: RatingControl!
    
    var chosenJobId: String!
    var bossId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // On confirmation, we can possibly delete the job (I think Manasa is handling this somewhere else, so probably leave out).
    @IBAction func onConfirm(_ sender: UIButton) {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")

        // GOING THROUGH JOBS POSTED ARRAY
        databaseRef.child("users").child(self.bossId).child("jobsPostedArray").observe(FIRDataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                for jobsPostedSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
    
                    let jobsPostedObject = jobsPostedSnapshot.value as! [String: AnyObject]
                    let jobId = jobsPostedObject["jobId"] as! String
                    
                    // DELETE FROM POSTER'S POSTED! @TODO: UNCOMMENT!
                    if (jobId == self.chosenJobId) {
//                        databaseRef.child("users").child(self.bossId).child("jobsPostedArray").child(jobsPostedSnapshot.key).removeValue()
                    }
                }
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
