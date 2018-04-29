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
    
    @IBAction func onConfirm(_ sender: UIButton) {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
//        let jobRef = databaseRef.child("jobs").child(chosenJobId)
        
        // NEED TO DECIDE IF WE WANNA HAVE POSTED INFORMATION (might need two arrays cause it will complicate)
//
//        jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
//
//            let jobObject = snapshot.value as! [String: AnyObject]
//
//            let jobTitle = jobObject["jobTitle"] as! String
//            let jobDescription = jobObject["jobDescription"] as! String
//            let jobPayment = jobObject["jobPayment"] as! Double
//
//            let userRef = databaseRef.child("users").child(self.bossId)
//            userRef.observeSingleEvent(of: .value, with: {(snap) in
//
//                let userObject = snap.value as! [String: AnyObject]
//
//                let numJobsCompleted = userObject["jobsCompleted"] as! Int
//                let reviewStar = self.ratingStars.rating
//                let newPost = databaseRef.child("completedJobs").childByAutoId()
//
//                userRef.child("jobsPostedArray")
//
//                let values = ["jobTitle": jobTitle, "jobDescription": jobDescription, "jobPayment": jobPayment, "jobRating" : reviewStar, "jobReview": self.reviewTextField.text!] as [String : Any]
//                newPost.setValue(values)
//
//                self.dismiss(animated: true, completion: nil)
//            })
//
//        })
        
        // GOING THROUGH JOBS POSTED ARRAY
        databaseRef.child("users").child(self.bossId).child("jobsPostedArray").observe(FIRDataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                for jobsPostedSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
//                    print("I AM JOBS SNAPSHOT", jobsPostedSnapshot.key)
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
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
