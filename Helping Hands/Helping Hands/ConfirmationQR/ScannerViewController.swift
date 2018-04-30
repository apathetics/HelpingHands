//
//  ScannerViewController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseAuth

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topbar: UIView!
    
    // AV Capture and Preview Layer intialization
    var captureSession:AVCaptureSession? = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var scannedId: String!
    var segueDone = false
    
    let userId: String = (FIRAuth.auth()?.currentUser?.uid)!
    
    @IBAction func onPaymentClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "showPaymentHired", sender: self)
    }
    @IBAction func onBackClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //  ** PREPARE SEGUES ** \\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showPaymentHired") {
            let vc:HiredPaymentController = segue.destination as! HiredPaymentController
            
            vc.chosenJobId = self.scannedId
            
            let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
            let jobRef = databaseRef.child("jobs").child(scannedId)
            
            jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                
                let jobObject = snapshot.value as! [String: AnyObject]
                
                vc.moneyLabel.text = String(jobObject["jobPayment"] as! Double)
                
                let payerId = jobObject["jobCreator"] as! String
                
                vc.bossId = payerId
                
                databaseRef.child("users").child(payerId).observeSingleEvent(of: .value, with: {(snap) in
                    let userObject = snap.value as! [String: AnyObject]
                    
                    let firstName = userObject["firstName"] as! String
                    let lastName = userObject["lastName"] as! String
                    
                    vc.payerLabel.text = "\(firstName) \(lastName)"
                })
            })
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the BACK-facing camera for capturing videos by using discovery
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        
        // If there is no device discovered, then fail
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Start video capture.
        captureSession?.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: topbar)
        
    }
    
    // QR Code Detection Protocol
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                let qrValue = metadataObj.stringValue
                messageLabel.text = metadataObj.stringValue
                self.scannedId = qrValue
                
                let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")
                let jobRef = databaseRef.child("jobs").child(qrValue!)
                
                jobRef.observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    let jobObject = snapshot.value as! [String: AnyObject]
                    
                    let qrFlag = jobObject["QRCodeFlag"] as! Bool
                    
                    if (qrFlag && self.segueDone == false) {
                        
                        print("GROUP ENTER")
                        jobRef.updateChildValues(["scannerFlag" : true])
                        jobRef.updateChildValues(["completedBy" : self.userId])
                        print("GROUP LEAVE")
                        
                        self.segueDone = true
                        self.performSegue(withIdentifier: "showPaymentHired", sender: self)
                    }
                })
                
            }
        }
    }

}
