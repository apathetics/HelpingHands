//
//  QRViewController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class QRViewController: UIViewController, Themeable {
    @IBOutlet weak var scanLBL: UILabel!
    @IBOutlet weak var paymentBTN: UIButton!
    @IBOutlet weak var qrCodeBox: UIImageView!
    
    var chosenJobId: String!
    
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Theme
        ThemeService.shared.addThemeable(themable: self)
        
        // QR codes are always square so make sure width == height if playing with constraints
        // Hash using job ID
        let myQRimage = createQRFromString(self.chosenJobId, size: qrCodeBox.frame.size)
        qrCodeBox.image = myQRimage
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
        let jobRef = databaseRef.child("jobs").child(chosenJobId)
        
        jobRef.observe(.value, with: {(snapshot) in
            
            let jobObject = snapshot.value as! [String: AnyObject]
            let qrFlag = jobObject["QRCodeFlag"] as! Bool
        
            // If scannerFlag has been set from scanner, then we transition to next screen (handshake).
            if (jobObject["scannerFlag"] != nil) {
                self.performSegue(withIdentifier: "showPaymentHiring", sender: self)
            }
        })
    }
    
    //  ** PREPARE SEGUES ** \\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // When we transition to payment screen, we want to pull data from who completed the scan and fill the screen with that info.
        if(segue.identifier == "showPaymentHiring") {
            
            let vc:HiringPaymentController = segue.destination as! HiringPaymentController
            vc.chosenJobId = self.chosenJobId
            
            let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
            let jobRef = databaseRef.child("jobs").child(self.chosenJobId)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    let jobObject = snapshot.value as! [String: AnyObject]
                    let completedById = jobObject["completedBy"] as! String
                    
                    vc.moneyLabel.text = String(jobObject["jobPayment"] as! Double)
                    
                    databaseRef.child("users").child(completedById).observeSingleEvent(of: .value, with: {(snap) in
                        
                        let userObject = snap.value as! [String: AnyObject]
                        let firstName = userObject["firstName"] as! String
                        let lastName = userObject["lastName"] as! String
                        
                        vc.recipientLabel.text = "\(firstName) \(lastName)"
                    })
                })
            }
        }
    }
    
    // Creating the QR image from string
    func createQRFromString(_ str: String, size: CGSize) -> UIImage {
        let stringData = str.data(using: .utf8)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        let minimalQRimage = qrFilter.outputImage!
        // NOTE that a QR code is always square, so minimalQRimage..width === .height
        let minimalSideLength = minimalQRimage.extent.width
        
        let smallestOutputExtent = (size.width < size.height) ? size.width : size.height
        let scaleFactor = smallestOutputExtent / minimalSideLength
        let scaledImage = minimalQRimage.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        return UIImage(ciImage: scaledImage, scale: UIScreen.main.scale, orientation: .up)
    }
    
    // This is a button that is used for emergency testing (if handshake does not go through)
    @IBAction func onClickPayment(_ sender: Any) {
        self.performSegue(withIdentifier: "showPaymentHiring", sender: self)
    }
    
    func applyTheme(theme: Theme) {
        if(self.navigationController == nil) {
            // big fix: UserVC->navigationController is nil after clicking back button
            UINavigationController(rootViewController: self)
        }
        
        theme.applyBackgroundColor(views: [self.view])
        theme.applyHeadlineStyle(labels: [scanLBL])
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyButtonTextStyle(buttons: [paymentBTN])
    }
}
