//
//  EditEventViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/21/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorageUI

class EditEventViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, Themeable {
    
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var editEventTitle: UITextField!
    @IBOutlet weak var editEventHelpers: UITextField!
    @IBOutlet weak var editEventDate: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var chooseImgButton: UIButton!
    
    var imgChosen = false
    var masterView:EventViewController?
    var event:Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        eventPhoto.image = event.image
        editEventTitle.text = event.eventTitle
        editEventHelpers.text = String(event.numHelpers)
        editEventDate.text = event.eventDateString
        eventDescription.text = event.eventDescription
        
        // TODO when location is more than an illusion
        editLocation.text = "curLocation"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        if imgChosen == false {
            eventPhoto.sd_setImage(with: URL(string: self.event.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                //            self.event.image = image
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if eventDescription.textColor == UIColor.lightGray {
            eventDescription.text = nil
            eventDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if eventDescription.text.isEmpty {
            eventDescription.text = "Description..."
            eventDescription.textColor = UIColor.lightGray
        }
    }
    
    func getDate(date: NSDate) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MM/dd/yyyy"
        return dateFormate.string(from: date as Date)
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
            eventPhoto.image = image
            
            self.imgChosen = true
        } else {
            //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // UPDATE FIREBASE REFERENCE VALUES INSTEAD OF event
    @IBAction func saveChanges(_ sender: Any) {
        event.image = eventPhoto.image
        event.eventTitle = editEventTitle.text
        event.numHelpers = Int(editEventHelpers.text!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        event.date = dateFormatter.date (from: editEventDate.text!)
        event.eventDescription = eventDescription.text
        
        masterView?.e = self.event
        updateEvent(e: self.event)
        self.performSegueToReturnBack()
    }
    
    // Update the events by replacing values from current e instance
    func updateEvent(e: Event) {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-2-backup.firebaseio.com/")
        let eventRef = databaseRef.child("events").child(e.eventId)
        if let imgUpload = UIImagePNGRepresentation(e.image!) {
            let imgName = NSUUID().uuidString // Unique name for each image to be stored in Firebase Storage
            let storageRef = FIRStorage.storage().reference().child("\(imgName).png")
            storageRef.put(imgUpload, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let eventImgUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["eventTitle": e.eventTitle, "eventImageUrl": eventImgUrl, "eventDistance": e.distance, "eventDescription": e.eventDescription, "eventDate": e.eventDateString, "eventCurrentLocation": e.currentLocation, "eventAddress": e.address, "eventNumHelpers": e.numHelpers, "eventCreator":(FIRAuth.auth()?.currentUser?.uid)!] as [String : Any]
                    eventRef.setValue(values)
                }
            })
        }
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyTextViewStyle(textViews: [eventDescription])
        theme.applyFilledButtonStyle(buttons: [chooseImgButton])
        theme.applyTextFieldStyle(textFields: [editEventTitle, editEventDate, editEventHelpers, editLocation])
    }
    
}

