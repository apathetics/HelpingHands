//
//  AddEventViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/13/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class AddEventViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleFld: UITextField!
    @IBOutlet weak var descriptionFld: UITextView!
    @IBOutlet weak var addressFld: UITextView!
    @IBOutlet weak var helpersCountFld: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var redLbl: UILabel!
    @IBOutlet weak var locImg: UIImageView!
    
    var imgChosen = false
    var masterView:CommunityTabViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionFld.delegate = self
        descriptionFld.text = DESCR_PLACEHOLDER
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locImg.isHighlighted = true
        // set the date picker's mininum value to now
        datePicker.minimumDate = Date()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // should be called when a text view is in focus
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == DESCR_PLACEHOLDER) {
            textView.text = ""
            textView.textColor = .black
            textView.becomeFirstResponder()
        }
    }
    
    // should be called when a text view has lost focus
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.isEqual(descriptionFld) == true) {
            if (textView.text == "") {
                textView.text = DESCR_PLACEHOLDER
                textView.textColor = .lightGray
            }
        }
    }
    
    // if the location switch is enabled, the user's location will be used
    // as the event location. If not, the user must enter a valid US address.
    @IBAction func locationSwitch(_ sender: UISwitch) {
        if (sender.isOn == false) {
            addressFld.isEditable = true
            addressFld.isSelectable = true
            addressFld.text = ""
            addressFld.textColor = .black
            addressFld.becomeFirstResponder()
            locImg.isHighlighted = false
        } else {
            addressFld.text = LOC_DEFAULT_TEXT
            addressFld.textColor = .lightGray
            addressFld.isEditable = false
            addressFld.isSelectable = false
            locImg.isHighlighted = true
        }
    }
    
    @IBAction func helperStep(_ sender: UIStepper) {
        let val:Int = Int(sender.value)
        helpersCountFld.text = String(val)
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
            imgView.image = image
            self.imgChosen = true
        } else {
            //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDoubleFromString(str:String) -> Double {
        var result:Double?
        if str == "" {
            return 0;
        }
        if (Double(str) == nil) {
            return -1;
        } else {
            result = Double(str)
        }
        return result!
    }
    
    @IBAction func finishBtn(_ sender: Any) {
        if titleFld.text == "" || descriptionFld.text == DESCR_PLACEHOLDER {
            redLbl.text = "All fields are required."
            redLbl.isHidden = false
        } else if (datePicker.date < Date()) {
            redLbl.text = "That time is in the past!"
            redLbl.isHidden = false
        } else if (imgChosen == false) {
            redLbl.text = "You must choose an image."
            redLbl.isHidden = false
        } else {
            // everything else should be fine...
            // make a Event object and return to previous screen
            let event:Event = Event()
            event.eventTitle = titleFld.text
            event.eventDescription = descriptionFld.text
            event.date = datePicker.date
            event.distance = 0.0 // TODO
            event.numHelpers = Int(helpersCountFld.text!)!
            event.address = addressFld.text // TODO
            event.image = imgView.image
            masterView!.eventToAdd = event
            redLbl.isHidden = true
            
            // Add event to CoreData
            storeEvent(e: event)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func storeEvent(e: Event) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let event = NSEntityDescription.insertNewObject(
            forEntityName: "EventEntity", into: context)
        
        // Set the attribute values
        event.setValue(e.eventTitle, forKey: "eventTitle")
        event.setValue(0, forKey: "eventPayment")
        event.setValue(e.numHelpers, forKey: "eventNumHelpers")
        event.setValue(UIImagePNGRepresentation(e.image!)!, forKey: "eventImage")
        event.setValue(e.distance, forKey: "eventDistance")
        event.setValue(e.eventDescription, forKey: "eventDescription")
        event.setValue(e.date, forKey: "eventDate")
        event.setValue(e.currentLocation, forKey: "eventCurrentLocation")
        event.setValue(e.address, forKey: "eventAddress")
        // Commit the changes
        do {
            try context.save()
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
    }
    //----------------------------------------------------------------//
    
    // This method is called when the user touches the Return key on the
    // keyboard. The 'textField' passed in is a pointer to the textField
    // widget the cursor was in at the time they touched the Return key on
    // the keyboard.
    //
    // From the Apple documentation: Asks the delegate if the text field
    // should process the pressing of the return button.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

