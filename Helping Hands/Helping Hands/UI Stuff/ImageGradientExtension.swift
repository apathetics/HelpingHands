//
//  ImageGradientExtension.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 3/22/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = self.bounds
        CATransaction.commit()
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x:1.0, y:1.0)
        gradientLayer.endPoint = CGPoint(x:0.0, y:0.0)
        layer.insertSublayer(gradientLayer, at: 0)
       
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        self.addSubview(overlay)
    }
}
