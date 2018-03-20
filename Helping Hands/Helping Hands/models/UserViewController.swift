//
//  UserViewController.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit
import CoreData

class UserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    var imgChosen = false
    var masterView:JobViewController?
    var clearCore: Bool = false
    
    // TODO - Pass using database
    var user:User?
    var userIndexPath:Int?
    

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userFirstName: UILabel!
    @IBOutlet weak var userLastName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userDistance: UILabel!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var editFirstName: UITextField!
    @IBOutlet weak var editLastName: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editLocation: UITextField!
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var jobBar: UISegmentedControl!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var saveEditButton: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(user?.userID != 1) {
            self.navigationItem.rightBarButtonItem =  nil;
        }
        
        userPhoto.image = user?.userPhoto
        userFirstName.text = user?.userFirstName
        userLastName.text = user?.userLastName
        userEmail.text = user?.userEmail
        userDescription.text = user?.userBio
        // Change the ones below
        userRating.text = String(describing: user?.userNumJobsPosted)
        userLocation.text = String(describing: user?.userLocationRadius)
        userDistance.text = String(describing: user?.userJobsCompleted)
        
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func editPress(_ sender: Any) {
        //userPhoto: UIImageView!
        userFirstName.isHidden = true
        userLastName.isHidden = true
        userEmail.isHidden = true
        userLocation.isHidden = true
        userDescription.isUserInteractionEnabled = true
        userDescription.isEditable = true
        jobBar.isHidden = true
        table.isHidden = true
        
        chooseImgButton.isHidden = false
        editFirstName.isHidden = false
        editLastName.isHidden = false
        editEmail.isHidden = false
        editLocation.isHidden = false
        saveEditButton.isHidden = false
        editFirstName.text = userFirstName.text
        editLastName.text = userLastName.text
        editEmail.text = userEmail.text
        editLocation.text = userLocation.text
        
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
            userPhoto.image = image
            self.imgChosen = true
        } else {
            //error
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        userFirstName.isHidden = false
        userLastName.isHidden = false
        userEmail.isHidden = false
        userLocation.isHidden = false
        userDescription.isUserInteractionEnabled = false
        userDescription.isEditable = false
        jobBar.isHidden = false
        table.isHidden = false
        
        chooseImgButton.isHidden = true
        editFirstName.isHidden = true
        editLastName.isHidden = true
        editEmail.isHidden = true
        editLocation.isHidden = true
        saveEditButton.isHidden = true
        
        user?.userFirstName = editFirstName.text
        user?.userLastName = editLastName.text
        user?.userEmail = editEmail.text
        // TODO
        //user?.userLocationRadius = Double(editLocation.text)
        user?.userBio = userDescription.text
        // TODO
        // Might cause problems if user decides not to save - Watch out
        user?.userPhoto = userPhoto.image
        
        userPhoto.image = user?.userPhoto
        userFirstName.text = user?.userFirstName
        userLastName.text = user?.userLastName
        userEmail.text = user?.userEmail
        userLocation.text = String(describing: user?.userLocationRadius)
        userDescription.text = user?.userBio
        
        masterView?.inquiries[userIndexPath!] = user!
    }
    
    /*
     override func viewWillAppear(_ animated: Bool) {
     inquiries = [NSManagedObject]()
     
     for user in retrieveinquiries() {
     inquiries.append(user)
     }
     
     //table.reloadData()
     }*/
    /*
     func retrieveinquiries() -> [NSManagedObject] {
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let context = appDelegate.persistentContainer.viewContext
     
     let request = NSFetchRequest<NSFetchRequestResult>(entityName:"userEntity")
     var fetchedResults:[NSManagedObject]? = nil
     
     // Examples of filtering using predicates
     // let predicate = NSPredicate(format: "age = 35")
     // let predicate = NSPredicate(format: "name CONTAINS[c] 'ake'")
     // request.predicate = predicate
     
     do {
     try fetchedResults = context.fetch(request) as? [NSManagedObject]
     } catch {
     // If an error occurs
     let nserror = error as NSError
     NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
     abort()
     }
     
     return(fetchedResults)!
     
     }
     
     func clearCoreuser() {
     
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let context = appDelegate.persistentContainer.viewContext
     
     let request = NSFetchRequest<NSFetchRequestResult>(entityName: "userEntity")
     var fetchedResults:[NSManagedObject]
     
     do {
     try fetchedResults = context.fetch(request) as! [NSManagedObject]
     
     if fetchedResults.count > 0 {
     
     for result:AnyObject in fetchedResults {
     context.delete(result as! NSManagedObject)
     print("\(result.value(forKey: "userTitle")!) has been Deleted")
     }
     }
     try context.save()
     
     } catch {
     // If an error occurs
     let nserror = error as NSError
     NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
     abort()
     }
     
     }
     */
}
