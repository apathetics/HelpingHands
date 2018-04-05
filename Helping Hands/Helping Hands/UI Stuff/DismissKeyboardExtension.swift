//
//  DismissKeyboardExtension.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 4/4/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
