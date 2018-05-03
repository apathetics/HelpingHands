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

class HiringPaymentController: UIViewController, Themeable {
    
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var youAreLabel: UILabel!
    @IBOutlet weak var tipSwich: UISegmentedControl!
    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var ratingStars: RatingControl!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    
    var chosenJobId: String!
    var bossId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // On confirmation, we want to update the person who completed the job's rating/review and update their jobsCompleted array.
    @IBAction func onConfirm(_ sender: UIButton) {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
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
                
                // Increment number of jobs completed
                userRef.updateChildValues(["jobsCompleted" : numJobsCompleted + 1])
                
                // Update the user rating and if nil, automatically default to 5.
                var userRating = userObject["userRating"] as? Double
                if(userRating == nil) {
                    userRating = 5.0
                }
                else {
                    userRating = userRating! * numJobsCompleted
                    userRating = (userRating! + Double(reviewStar)) / Double(numJobsCompleted + 1.0)
                }
                
                userRef.updateChildValues(["userRating" : userRating!, "moneyEarned": moneyEarned + jobPayment])
                
                // Make a new database post for a completedJob so that we can remove it from the actual user table.
                let newPost = databaseRef.child("completedJobs").childByAutoId()
                let values = ["jobTitle": jobTitle, "jobDescription": jobDescription, "jobPayment": jobPayment, "jobRating" : reviewStar, "jobReview": self.reviewTextField.text!, "jobImageUrl": jobImageUrl] as [String : Any]
                newPost.setValue(values)

                let jobCompletedChild = userRef.child("jobsCompletedArray").childByAutoId()
                jobCompletedChild.setValue(["jobId": newPost.key])
                
                // GOING THROUGH JOBS INQUIRED ARRAY
                // Possibly delete inquired arrays, but leave commented out because I think Manasa has taken care of this elsewhere.
                databaseRef.child("users").child(jobCompletedBy).child("jobsInquiredArray").observe(FIRDataEventType.value, with: {(snapshot) in
                    if snapshot.childrenCount > 0 {
                        for jobsPostedSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                            let jobsPostedObject = jobsPostedSnapshot.value as! [String: AnyObject]
                            
                            let jobId = jobsPostedObject["jobId"] as! String
                            
                            // DELETE FROM POSTER'S POSTED! @TODO: UNCOMMENT!
                            if (jobId == self.chosenJobId) {
//                                databaseRef.child("users").child(jobCompletedBy).child("jobsInquiredArray").child(jobsPostedSnapshot.key).removeValue()
                            }
                        }
                    }
                })
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
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyHeadlineStyle(labels: [recipientLabel, moneyLabel, toLabel, rateLabel, youAreLabel, tipLabel])
        theme.applySegmentedControlStyle(controls: [tipSwich])
        theme.applyFilledButtonStyle(buttons: [confirmButton])
        theme.applyTextFieldTextStyle(textFields: [reviewTextField])
        theme.applyTextFieldStyle(color: UIColor(hex: "fdfdfd"), textFields: [reviewTextField])
    }
}
