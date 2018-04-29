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

class EditEventViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, AddressDelegate, Themeable {
    
    @IBOutlet weak var editEventView: UIView!
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var editEventTitle: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var locationEditButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var numHelpersText: UITextField!
    
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var numHelpersButton: UIStepper!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var requiredLabel: UILabel!
    @IBOutlet weak var numHelpersLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var imgChosen = false
    var masterView:EventViewController?
    var event:Event!
    var address:String?
    var latLong:(Double, Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        self.hideKeyboardWhenTappedAround()
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        eventPhoto.sd_setImage(with: URL(string: self.event.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            self.event.image = image
        })
        
        eventPhoto.image = event.image
        editEventTitle.text = event.eventTitle
        numHelpersText.text = String(event.numHelpers)
        
        eventDescription.text = event.eventDescription
        self.latLong = (event.latitude, event.longitude)
        
        // TODO when location is more than an illusion
        addressLabel.text = event.address
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(address != nil) {
            addressLabel.text = address!
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
    
    func sendAddress(address:String, latLong:(Double, Double)) {
        self.address = address
        self.latLong = latLong
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditEventLocation" {
            let goNext:LocationViewController = segue.destination as! LocationViewController
            goNext.delegate = self
        }
    }
    
    @IBAction func helperStep(_ sender: UIStepper) {
        let val:Int = Int(sender.value)
        numHelpersText.text = String(val)
    }
    
    // UPDATE FIREBASE REFERENCE VALUES INSTEAD OF event
    @IBAction func saveChanges(_ sender: Any) {
        event.image = eventPhoto.image
        event.eventTitle = editEventTitle.text
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let datePicked = df.string(from: datePicker.date)
        let dateFromString = df.date(from: datePicked)
        df.dateFormat = "MMM dd, yyyy 'at' K:mm aaa"
        event.eventDateString = df.string(from: dateFromString!)
        
        event.eventDescription = eventDescription.text
        
        if(self.latLong != nil) {
            event.latitude = self.latLong?.0
            event.longitude = self.latLong?.1
        }
        
        event.address = addressLabel.text
        event.date = datePicker.date
        event.numHelpers = Int(numHelpersText.text!)!
        
        masterView?.e = self.event
        updateEvent(e: self.event)
        self.performSegueToReturnBack()
    }
    
    // Update the events by replacing values from current e instance
    func updateEvent(e: Event) {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
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
                    eventRef.updateChildValues(["latitude": self.latLong!.0, "longitude": self.latLong!.1])
                }
            })
        }
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, editEventView])
        theme.applyHeadlineStyle(labels: [dateLabel, eventDescriptionLabel, eventTitleLabel, numHelpersLabel, eventLocationLabel, addressLabel])
        theme.applyStepperStyle(steppers: [numHelpersButton])
        theme.applyFilledButtonStyle(buttons: [chooseImgButton, locationEditButton])
        theme.applyTextViewStyle(textViews: [eventDescription])
        theme.applyTextFieldTextStyle(textFields: [editEventTitle])
        theme.applyDatePickerStyle(pickers: [datePicker])
    }
    
}

