//
//  QRViewController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit

class QRViewController: UIViewController {
    
    @IBOutlet weak var qrCodeBox: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // QR codes are always square so make sure width == height if playing with constraints
        let myQRimage = createQRFromString("https://www.apple.com", size: qrCodeBox.frame.size)
        qrCodeBox.image = myQRimage
    }
    
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
}
