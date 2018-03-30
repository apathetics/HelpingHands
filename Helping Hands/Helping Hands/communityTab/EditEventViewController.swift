//
//  EditEventViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/21/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class EditEventViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var eventPhoto: UIImageView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var editEventTitle: UITextField!
    @IBOutlet weak var editEventHelpers: UITextField!
    @IBOutlet weak var editEventDate: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var chooseImgButton: UIButton!
    
    var imgChosen = false
    // TODO - Pass using database, DELETE MASTERVIEW WHEN SAVECHANGES
    // REFERS TO FIREBASE
    var masterView:EventViewController?
    var clearCore: Bool = false
    var event:Event!
    // TODO - Pass using database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventPhoto.image = event.image
        editEventTitle.text = event.eventTitle
        editEventHelpers.text = String(event.numHelpers)
        editEventDate.text = event.eventDateString
        eventDescription.text = event.eventDescription
        
        // TODO when location is more than an illusion
        editLocation.text = "curLocation"
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
         if clearCore {
         clearCoreevent()
         }*/
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
        self.performSegueToReturnBack()
    }
    
    
}

