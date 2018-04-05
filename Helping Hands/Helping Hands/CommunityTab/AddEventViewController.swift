//
//  AddEventViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/13/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class AddEventViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, AddressDelegate, Themeable {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleFld: UITextField!
    @IBOutlet weak var descriptionFld: UITextView!
    @IBOutlet weak var helpersCountFld: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var redLbl: UILabel!
    @IBOutlet weak var locImg: UIImageView!
    @IBOutlet weak var addEventView: UIView!
    
    @IBOutlet weak var finishBTN: UIButton!
    @IBOutlet weak var chooseImgBTN: UIButton!
    @IBOutlet weak var eventTitleLBL: UILabel!
    @IBOutlet weak var eventDescLBL: UILabel!
    @IBOutlet weak var eventLocationLBL: UILabel!
    @IBOutlet weak var helpersGoalLBL: UILabel!
    @IBOutlet weak var eventDateLBL: UILabel!
    @IBOutlet weak var helperStepper: UIStepper!
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var chooseLocationBTN: UIButton!
    
    var imgChosen = false
    var masterView:CommunityTabViewController?
    var address:String?
    var latLong:(Double, Double)?
    
    override func viewDidLoad() {
        ThemeService.shared.addThemeable(themable: self)
        super.viewDidLoad()
        descriptionFld.delegate = self
        descriptionFld.text = DESCR_PLACEHOLDER
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locImg.isHighlighted = true
        if(address != nil) {
            addressLBL.text = address!
        }
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
            
            // Format the date before saving as a string (database won't take NSDate)
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let datePicked = df.string(from: datePicker.date)
            let dateFromString = df.date(from: datePicked)
            df.dateFormat = "dd-MMM-yyyy"
            let eventDateAsString = df.string(from: dateFromString!)
            
            let event:Event = Event()
            event.eventTitle = titleFld.text
            event.eventDescription = descriptionFld.text
            event.date = datePicker.date
            event.eventDateString = eventDateAsString
            event.distance = 0.0 // TODO
            event.numHelpers = Int(helpersCountFld.text!)!
            event.address = self.address // TODO
            event.image = imgView.image
            redLbl.isHidden = true
            
            // TODO: Give actual address and current location!
            event.address = self.address
            event.currentLocation = true
            
            // Add event to database
            storeEvent(e: event)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // Database
    func storeEvent(e: Event) {
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
        let postRef = databaseRef.child("events")
        let newPost = postRef.childByAutoId()
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
                    newPost.setValue(values)
                    newPost.updateChildValues(["latitude": self.latLong!.0, "longitude": self.latLong!.1])
                }
            })
        }
        
        let userId:String = (FIRAuth.auth()?.currentUser?.uid)!
        let eventPostedChild = databaseRef.child("users").child(userId).child("eventsPostedArray").childByAutoId()
        eventPostedChild.setValue([newPost.key: newPost.key])
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
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view, addEventView])
        theme.applyDatePickerStyle(pickers: [datePicker])
        theme.applyFilledButtonStyle(buttons: [finishBTN, chooseImgBTN, chooseLocationBTN])
        theme.applyHeadlineStyle(labels: [eventTitleLBL, eventDescLBL, eventLocationLBL, helpersGoalLBL, eventDateLBL, addressLBL])
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyTextViewStyle(textViews: [descriptionFld])
        theme.applyTextFieldStyle(textFields: [titleFld, helpersCountFld])
        theme.applyStepperStyle(steppers: [helperStepper])
    }
    
    func sendAddress(address:String, latLong:(Double, Double)) {
        self.address = address
        self.latLong = latLong
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddEventLocation" {
            let goNext:LocationViewController = segue.destination as! LocationViewController
            goNext.delegate = self
        }
    }
}

