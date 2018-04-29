//
//  RegistrationVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class RegistrationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
    
    // outlets
    
    @IBOutlet weak var termsAgreementsCB: BEMCheckBox!
    @IBOutlet weak var over18CB: BEMCheckBox!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    // actions
    
    @IBAction func UploadImagePressed(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        //imagePickerController.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title:"Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera Not Available")
            }
        }))
        actionSheet.addAction(UIAlertAction(title:"Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }

    
    
    @IBAction func signUpPressed(_ sender: Any) {
        // Make sure none of the fields are empty
        // (image is optional, placeholder will be used if none specified)
        if firstNameTF.text == "" || lastNameTF.text == "" || emailTF.text! == "" || passwordTF.text! == "" || confirmPasswordTF.text == "" {
            let alert = UIAlertController(title: "Empty Fields!",
                                          message: "Make sure all the fields are completed",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Make sure both passwords match
        if passwordTF.text != confirmPasswordTF.text {
            passwordTF.text = ""
            confirmPasswordTF.text = ""
            let alert = UIAlertController(title: "Password Mismatch",
                                          message: "The passwords you entered did not match. Please try again.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        if let email = emailTF.text, let pass = passwordTF.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { user, error in
                if error != nil {
                    // error handler
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        var title: String = ""
                        var message: String = ""
                        var log: String = ""
                        
                        switch errCode {
                        case .errorCodeWeakPassword:
                            title = "Weak Password"
                            message = "The password you entered doesn't appear to be strong enough. Please enter a new one and try again."
                            log = "Weak Password Alert Displayed"
                        case .errorCodeInvalidEmail:
                            title = "Invalid Email"
                            message = "The email you entered doesn't appear to be a valid email address. Please enter a new one and try again."
                            log = "Invalid Email Alert Displayed"
                        default:
                            title = "Invalid Credentials"
                            message = "The credentials you entered are invalid. Please try again."
                            log = "Other error Alert Displayed"
                        }
                        //display alert
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            NSLog(log)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    guard let uid = user?.uid else {
                        return
                    }
                    print("Registration Success!")
                    if let imgUpload = UIImagePNGRepresentation(self.profileImage.image!) {
                        let imgName = NSUUID().uuidString // Unique name for each image to be stored in Firebase Storage
                        let storageRef = FIRStorage.storage().reference().child("\(imgName).png")
                        storageRef.put(imgUpload, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error)
                                return
                            }
                            if let profileImgUrl = metadata?.downloadURL()?.absoluteString {
                                let values = ["firstName": self.firstNameTF.text!, "lastName": self.lastNameTF.text!, "email": self.emailTF.text!, "photoUrl": profileImgUrl, "jobsCompleted": 0, "jobsPosted": 0, "moneyEarned": 0] as [String : Any]
                                self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                            }
                        })
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
//        let user = FIRAuth.auth()?.currentUser
//        if let user = user {
//            let changeRequest = user.profileChangeRequest()
//        }
    }
    
    // methods
    
    func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]){
        let userReference = self.databaseRef.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ImagePickerController Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImage.image = image.fixOrientation()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

