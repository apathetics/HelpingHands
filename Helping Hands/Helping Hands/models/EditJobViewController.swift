//
//  EditJobViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/21/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import Foundation

class EditJobViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var jobPhoto: UIImageView!
    @IBOutlet weak var jobDescription: UITextView!
    @IBOutlet weak var editJobTitle: UITextField!
    @IBOutlet weak var editJobPrice: UITextField!
    @IBOutlet weak var editJobDate: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var chooseImgButton: UIButton!
    
    var imgChosen = false
    // TODO - Pass using database
    var masterView:JobViewController?
    var clearCore: Bool = false
    var job:Job!
    // TODO - Pass using database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobPhoto.image = job.image
        editJobTitle.text = job.jobTitle
        editJobPrice.text = String(job.payment)
        editJobDate.text = job.jobDateString
        jobDescription.text = job.jobDescription
        
        // TODO when location is more than an illusion
        editLocation.text = "curLocation"
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
         if clearCore {
         clearCorejob()
         }*/
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
        self.performSegueToReturnBack()
    }
}

