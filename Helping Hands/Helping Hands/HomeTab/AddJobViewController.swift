//
//  AddJobViewController.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/13/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

let LOC_DEFAULT_TEXT = "Using your current location by default. You can use the toggle to the right to change this."
let DESCR_PLACEHOLDER = "What will Helpers be doing at this job? Add as much or little detail as you'd like, but make sure to be clear. You'll be more likely to attract Helpers that way!"

class AddJobViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AddressDelegate, UITextViewDelegate, Themeable {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleFld: UITextField!
    @IBOutlet weak var descriptionFld: UITextView!
    @IBOutlet weak var paymentFld: UITextField!
    @IBOutlet weak var paymentTypeSeg: UISegmentedControl!
    @IBOutlet weak var helpersCountFld: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var redLbl: UILabel!
    @IBOutlet weak var locImg: UIImageView!
    @IBOutlet weak var addJobView: UIView!
    @IBOutlet weak var jobTitleLBL: UILabel!
    @IBOutlet weak var jobDescLBL: UILabel!
    @IBOutlet weak var paymentLBL: UILabel!
    @IBOutlet weak var dollarSignLBL: UILabel!
    @IBOutlet weak var jobLocationLBL: UILabel!
    @IBOutlet weak var numHelpersLBL: UILabel!
    @IBOutlet weak var jobDateLBL: UILabel!
    @IBOutlet weak var addressLBL: UILabel!
    @IBOutlet weak var helpersStepper: UIStepper!
    @IBOutlet weak var finishBTN: UIButton!
    @IBOutlet weak var chooseImgBTN: UIButton!
    @IBOutlet weak var datePickerItem: UIDatePicker!
    @IBOutlet weak var chooseLocationBTN: UIButton!
    
    var imgChosen = false
    var masterView:HomeTabViewController?
    var address:String?
    var latLong:(Double, Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ThemeService.shared.addThemeable(themable: self)
        descriptionFld.delegate = self
        descriptionFld.text = DESCR_PLACEHOLDER
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locImg.isHighlighted = true
        // set the date picker's mininum value to now
        if(address != nil) {
            addressLBL.text = address!
        }
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
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
            imgView.image = image.fixOrientation()
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
        if titleFld.text == "" || descriptionFld.text == DESCR_PLACEHOLDER || paymentFld.text == "" {
            redLbl.text = "All fields are required."
            redLbl.isHidden = false
        } else if (datePicker.date < Date()) {
            redLbl.text = "That time is in the past!"
            redLbl.isHidden = false
        } else if (getDoubleFromString(str: paymentFld.text!)) < 0 {
            redLbl.text = "Not a valid amount."
            redLbl.isHidden = false
        } else if (imgChosen == false) {
            redLbl.text = "You must choose an image."
            redLbl.isHidden = false
        } else {
            // everything else should be fine...
            // make a Job object and return to previous screen
            
            // Format the date before saving as a string (database won't take NSDate)
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let datePicked = df.string(from: datePicker.date)
            let dateFromString = df.date(from: datePicked)
            df.dateFormat = "MMM dd, yyyy 'at' K:mm aaa"
            let jobDateAsString = df.string(from: dateFromString!)
            
            let job:Job = Job()
            job.jobTitle = titleFld.text
            job.jobDescription = descriptionFld.text
            job.date = datePicker.date
            job.jobDateString = jobDateAsString
            job.isHourlyPaid = paymentTypeSeg.selectedSegmentIndex == 0 ? true : false
            job.distance = 0.0 // TODO
            job.payment = Double(paymentFld.text!)!
            job.numHelpers = Int(helpersCountFld.text!)!
            //job.address = addressFld.text // TODO
            
            // TODO: Give actual address and current location!
            job.address = self.address
            job.currentLocation = true
            
            job.image = imgView.image
            redLbl.isHidden = true
            
            // Add job to database
            storeJob(j: job)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    // Database
    func storeJob(j: Job) {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
        let postRef = databaseRef.child("jobs")
        let newPost = postRef.childByAutoId()
        if let imgUpload = UIImagePNGRepresentation(j.image!) {
            let imgName = NSUUID().uuidString // Unique name for each image to be stored in Firebase Storage
            let storageRef = FIRStorage.storage().reference().child("job_photos/\(newPost.key).png")
            storageRef.put(imgUpload, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                }
                if let jobImgUrl = metadata?.downloadURL()?.absoluteString {
                    
                    let values = ["jobTitle": j.jobTitle, "jobImageUrl": jobImgUrl, "jobDistance": j.distance, "jobDescription": j.jobDescription, "jobDate": j.jobDateString, "jobCurrentLocation": j.currentLocation, "jobAddress": j.address, "jobNumHelpers": j.numHelpers, "jobPayment": j.payment, "jobIsHourlyPaid": j.isHourlyPaid, "jobCreator":(FIRAuth.auth()?.currentUser?.uid)!] as [String : Any]
                    newPost.setValue(values)
                    newPost.updateChildValues(["latitude": self.latLong!.0, "longitude": self.latLong!.1])
                    print("job added successfully")
                    // Increment jobs posted in users by 1
                    let userRef = databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
                    userRef.observeSingleEvent(of: .value, with: {(snapshot) in
                        let userObject = snapshot.value as! [String: Any]
                        let jobsPosted = userObject["jobsPosted"] as! Int
                        userRef.updateChildValues(["jobsPosted": jobsPosted + 1])
                    })
                }
            })
        }
        
        // Add job ID to user's jobsPosted
        let userId:String = (FIRAuth.auth()?.currentUser?.uid)!
        let jobPostedChild = databaseRef.child("users").child(userId).child("jobsPostedArray").childByAutoId()
        jobPostedChild.setValue(["jobId": newPost.key])
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
        theme.applyBackgroundColor(views: [view, addJobView])
        theme.applyHeadlineStyle(labels: [paymentLBL, jobDateLBL, jobDescLBL, jobTitleLBL, numHelpersLBL, dollarSignLBL, jobLocationLBL, addressLBL])
        theme.applyStepperStyle(steppers: [helpersStepper])
        theme.applySegmentedControlStyle(controls: [paymentTypeSeg])
        theme.applyFilledButtonStyle(buttons: [finishBTN, chooseImgBTN, chooseLocationBTN])
        theme.applyTextViewStyle(textViews: [descriptionFld])
        theme.applyTextFieldTextStyle(textFields: [titleFld, paymentFld, helpersCountFld])
        theme.applyTextFieldStyle(color: UIColor(hex: "fdfdfd"), textFields: [titleFld, paymentFld, helpersCountFld])
        theme.applyDatePickerStyle(pickers: [datePickerItem])
    }
    
    func sendAddress(address:String, latLong:(Double, Double)) {
        self.address = address
        self.latLong = latLong
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddJobLocation" {
            let goNext:LocationViewController = segue.destination as! LocationViewController
            goNext.delegate = self
        }
    }
}
