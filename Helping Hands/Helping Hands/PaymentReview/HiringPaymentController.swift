//
//  HiringPaymentController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class HiringPaymentController: UIViewController {
    
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var tipSwich: UISegmentedControl!
    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var ratingStars: RatingControl!
    
    var chosenJobId: String!
    var bossId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
        let jobRef = databaseRef.child("jobs").child(chosenJobId)
        
        jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
        
            let jobObject = snapshot.value as! [String: AnyObject]

            let jobTitle = jobObject["jobTitle"] as! String
            let jobDescription = jobObject["jobDescription"] as! String
            let jobPayment = jobObject["jobPayment"] as! Double
            let jobCompletedBy = jobObject["completedBy"] as! String
            let jobImageUrl = jobObject["jobImageUrl"] as! String
            
            let userRef = databaseRef.child("users").child(jobCompletedBy)
            
            userRef.observeSingleEvent(of: .value, with: {(snap) in

                let userObject = snap.value as! [String: AnyObject]

                let numJobsCompleted = userObject["jobsCompleted"] as! Double
                let moneyEarned = userObject["moneyEarned"] as! Double
                let reviewStar = self.ratingStars.rating
                
                userRef.updateChildValues(["jobsCompleted" : numJobsCompleted + 1])
                
                // rating math
                var userRating = userObject["userRating"] as? Double
                if(userRating == nil) {
                    userRating = 5.0
                }
                else {
                    userRating = userRating! * numJobsCompleted
                    userRating = (userRating! + Double(reviewStar)) / Double(numJobsCompleted + 1.0)
                }
                
                userRef.updateChildValues(["userRating" : userRating!, "moneyEarned": moneyEarned + jobPayment])
                
                let newPost = databaseRef.child("completedJobs").childByAutoId()
                let values = ["jobTitle": jobTitle, "jobDescription": jobDescription, "jobPayment": jobPayment, "jobRating" : reviewStar, "jobReview": self.reviewTextField.text!, "jobImageUrl": jobImageUrl] as [String : Any]
                newPost.setValue(values)

                let jobCompletedChild = userRef.child("jobsCompletedArray").childByAutoId()
                jobCompletedChild.setValue(["jobId": newPost.key])
                
                self.dismiss(animated: true, completion: nil)
            })

        })
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
