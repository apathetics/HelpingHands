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

class EditJobViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, AddressDelegate {
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var editJobTitle: UITextField!
    @IBOutlet weak var editJobPrice: UITextField!
    @IBOutlet weak var editJobDate: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var locationEditButton: UIButton!
    
    var imgChosen = false
    var masterView:JobViewController?
    var job:Job!
    var address:String?
    var latLong:(Double, Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        jobPhoto.sd_setImage(with: URL(string: self.job.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            self.job.image = image
        })
        
        jobPhoto.image = job.image
        editJobTitle.text = job.jobTitle
        editJobPrice.text = String(job.payment)
        editJobDate.text = job.jobDateString
        jobDescription.text = job.jobDescription
        self.latLong = (job.latitude, job.longitude)
        
        // TODO when location is more than an illusion
        addressLabel.text = job.address
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(address != nil) {
            addressLabel.text = address!
        }
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
        
        if(self.latLong != nil) {
            job.latitude = self.latLong?.0
            job.longitude = self.latLong?.1
        }
        
        job.address = addressLabel.text
        
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
                    jobRef.updateChildValues(["latitude": self.latLong!.0, "longitude": self.latLong!.1])
                }
            })
        }
    }
    
    func sendAddress(address:String, latLong:(Double, Double)) {
        self.address = address
        self.latLong = latLong
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditJobLocation" {
            let goNext:LocationViewController = segue.destination as! LocationViewController
            goNext.delegate = self
        }
    }
}

