//
//  EditUserViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/20/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

class EditUserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var editFirstName: UITextField!
    @IBOutlet weak var editLastName: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var imgChosen = false
    // TODO - Pass using database
    var masterView:UserViewController?
    var clearCore: Bool = false
    var user:User!
    // TODO - Pass using database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPhoto.image = user.userPhoto
        editFirstName.text = user.userFirstName
        editLastName.text = user.userLastName
        editEmail.text = user.userEmail
        userDescription.text = user.userBio
        
        if(userDescription.text == "" || userDescription.text == nil) {
            userDescription.text = "Description..."
            userDescription.textColor = UIColor.lightGray
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        /*
         if clearCore {
         clearCoreuser()
         }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if userDescription.textColor == UIColor.lightGray {
            userDescription.text = nil
            userDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if userDescription.text.isEmpty {
            userDescription.text = "Description..."
            userDescription.textColor = UIColor.lightGray
        }
    }
    
    /*
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return inquiries.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell:userTableViewCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! userTableViewCell
     
     let row = indexPath.row
     let j:NSManagedObject = inquiries[row]
     
     cell.userTitleLbl.text = j.value(forKey: "userTitle") as? String
     cell.userDescriptionLbl.text = j.value(forKey: "userDescription") as? String
     cell.distanceLbl.text = String(j.value(forKey: "userDistance") as! Double) + " mi"
     let ftmPayment = "$" + ((j.value(forKey: "userPayment") as! Double).truncatingRemainder(dividingBy: 1) == 0 ? String(j.value(forKey: "userPayment") as! Int64) : String(j.value(forKey: "userPayment") as! Double))
     print("PAYMENT IS:", ftmPayment)
     cell.paymentLbl.text = j.value(forKey: "userIsHourlyPaid") as! Bool == true ? ftmPayment + "/hr" : ftmPayment
     cell.userImg.image = UIImage(data: j.value(forKey: "userImage") as! Data)
     
     return cell
     }*/
    
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
            userPhoto.image = image
            self.imgChosen = true
        } else {
            //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        user.userPhoto = userPhoto.image
        user.userFirstName = editFirstName.text
        user.userLastName = editLastName.text
        user.userEmail = editEmail.text
        user.userBio = userDescription.text
        masterView?.user = self.user
        self.performSegueToReturnBack()
    }
}
