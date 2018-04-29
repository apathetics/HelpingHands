//
//  EditUserViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/20/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FirebaseStorageUI

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}


class EditUserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, Themeable {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var editFirstName: UITextField!
    @IBOutlet weak var editLastName: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var bioLBL: UILabel!
    
    let userId:String = (FIRAuth.auth()?.currentUser?.uid)!
    
    var imgChosen = false
    var masterView:UserViewController?
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeService.shared.addThemeable(themable: self)
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        userPhoto.sd_setImage(with: URL(string: user.userPhotoAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            self.user.userPhoto = image
        })
        
        userPhoto.image = user.userPhoto
        editFirstName.text = user.userFirstName
        editLastName.text = user.userLastName
        editEmail.text = user.userEmail
        userDescription.text = user.userBio
        
        if(userDescription.text == "" || userDescription.text == nil) {
            userDescription.text = "Description..."
            userDescription.textColor = UIColor.lightGray
        }
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
    
//    @IBAction func onBackButtonClick(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        user.userPhoto = userPhoto.image
        user.userFirstName = editFirstName.text
        user.userLastName = editLastName.text
        user.userEmail = editEmail.text
        user.userBio = userDescription.text
        masterView?.user = self.user
        updateUser(u: user)
        self.performSegueToReturnBack()
    }
    
//    @IBAction func saveChanges(_ sender: Any) {
//        user.userPhoto = userPhoto.image
//        user.userFirstName = editFirstName.text
//        user.userLastName = editLastName.text
//        user.userEmail = editEmail.text
//        user.userBio = userDescription.text
//        masterView?.user = self.user
//        updateJob(u: user)
//        self.performSegueToReturnBack()
//    }
    
    func updateUser(u: User) {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
        let jobRef = databaseRef.child("users").child(self.userId)
        if let imgUpload = UIImagePNGRepresentation(u.userPhoto) {
            let imgName = NSUUID().uuidString // Unique name for each image to be stored in Firebase Storage
            let storageRef = FIRStorage.storage().reference().child("\(imgName).png")
            storageRef.put(imgUpload, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let jobImgUrl = metadata?.downloadURL()?.absoluteString {
                    jobRef.updateChildValues(["photoUrl": jobImgUrl, "firstName": u.userFirstName, "lastName": u.userLastName, "email": u.userEmail, "bio": u.userBio])
                }
            })
        }
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyTextViewStyle(textViews: [userDescription])
        theme.applyTextFieldTextStyle(textFields: [editLastName, editFirstName, editEmail, editLocation])
        theme.applyFilledButtonStyle(buttons: [chooseImgButton])
        theme.applyHeadlineStyle(labels: [bioLBL])
    }
}
