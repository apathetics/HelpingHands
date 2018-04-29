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

class QRViewController: UIViewController {
    
    @IBOutlet weak var qrCodeBox: UIImageView!
    var chosenJobId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // QR codes are always square so make sure width == height if playing with constraints
        // @TODO: Discuss how to hash a unique QR code from string?
        // Possibly just combine job date + job location (GPS string)?
        let myQRimage = createQRFromString(self.chosenJobId, size: qrCodeBox.frame.size)
        qrCodeBox.image = myQRimage
        
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
        let jobRef = databaseRef.child("jobs").child(chosenJobId)
        
        jobRef.observe(.value, with: {(snapshot) in
            
            let jobObject = snapshot.value as! [String: AnyObject]
            
            let qrFlag = jobObject["QRCodeFlag"] as! Bool
            
            if (jobObject["scannerFlag"] != nil) {
                self.performSegue(withIdentifier: "showPaymentHiring", sender: self)
            }
            
        })
    }
    
    //  ** PREPARE SEGUES ** \\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showPaymentHiring") {
            let vc:HiringPaymentController = segue.destination as! HiringPaymentController
            
            vc.chosenJobId = self.chosenJobId
            
            let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
            let jobRef = databaseRef.child("jobs").child(self.chosenJobId)
            
            jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                
                let jobObject = snapshot.value as! [String: AnyObject]
                
                vc.moneyLabel.text = String(jobObject["jobPayment"] as! Double)
                let completedById = jobObject["completedBy"] as! String
                
                databaseRef.child("users").child(completedById).observeSingleEvent(of: .value, with: {(snap) in
                    let userObject = snap.value as! [String: AnyObject]
                    
                    let firstName = userObject["firstName"] as! String
                    let lastName = userObject["lastName"] as! String
                    
                    vc.recipientLabel.text = "\(firstName) \(lastName)"
                })
            })
            
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
    @IBAction func onClickPayment(_ sender: Any) {
        self.performSegue(withIdentifier: "showPaymentHiring", sender: self)
    }
    @IBAction func onBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
