//
//  hiredPaymentController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit

class HiredPaymentController: UIViewController {
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var payerLabel: UILabel!
    @IBOutlet weak var reviewTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
