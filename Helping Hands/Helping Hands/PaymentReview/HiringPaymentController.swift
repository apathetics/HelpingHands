//
//  HiringPaymentController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit

class HiringPaymentController: UIViewController {
    
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var tipSwich: UISegmentedControl!
    @IBOutlet weak var reviewTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
    }
}