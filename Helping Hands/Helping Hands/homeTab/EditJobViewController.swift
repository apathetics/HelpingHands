//
//  EditJobViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/21/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorageUI

class EditJobViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var editJobTitle: UITextField!
    @IBOutlet weak var editJobPrice: UITextField!
    @IBOutlet weak var editJobDate: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var chooseImgButton: UIButton!
    
    var imgChosen = false
    var masterView:JobViewController?
    var job:Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobPhoto.image = job.image
        editJobTitle.text = job.jobTitle
        editJobPrice.text = String(job.payment)
        editJobDate.text = job.jobDateString
        jobDescription.text = job.jobDescription
        
        // TODO when location is more than an illusion
        editLocation.text = "curLocation"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if jobDescription.textColor == UIColor.lightGray {
            jobDescription.text = nil
            jobDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if jobDescription.text.isEmpty {
            jobDescription.text = "Description..."
            jobDescription.textColor = UIColor.lightGray
        }
    }

    @IBAction func chooseImgBtn(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true) {
            // after completion
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            jobPhoto.image = image
            self.imgChosen = true
        } else {
            //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // Save changes to local job instance and then send segue to back
    @IBAction func saveChanges(_ sender: Any) {
        job.image = jobPhoto.image
        job.jobTitle = editJobTitle.text
        job.payment = (editJobPrice.text! as NSString).doubleValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        job.date = dateFormatter.date (from: editJobDate.text!)
        job.jobDescription = jobDescription.text
        
        // TODO when location is more than an illusion
        job.address = editLocation.text
        
        masterView?.j = self.job
        updateJob(j: self.job)
        self.performSegueToReturnBack()
    }
    
    // Update the jobs by replacing values from current j instance
    func updateJob(j: Job) {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let jobRef = databaseRef.child("jobs").child(j.jobId)
        if let imgUpload = UIImagePNGRepresentation(j.image!) {
            let imgName = NSUUID().uuidString // Unique name for each image to be stored in Firebase Storage
            let storageRef = FIRStorage.storage().reference().child("\(imgName).png")
            storageRef.put(imgUpload, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let jobImgUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["jobTitle": j.jobTitle, "jobImageUrl": jobImgUrl, "jobDistance": j.distance, "jobDescription": j.jobDescription, "jobDate": j.jobDateString, "jobCurrentLocation": j.currentLocation, "jobAddress": j.address, "jobNumHelpers": j.numHelpers, "jobPayment": j.payment, "jobIsHourlyPaid": j.isHourlyPaid, "jobCreator":(FIRAuth.auth()?.currentUser?.uid)!] as [String : Any]
                    jobRef.setValue(values)
                }
            })
        }
    }
}

