//
//  TermsAndAgreementsVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 5/2/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation

class TermsAndAgreementsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.white
        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(hex:"1B212C"), NSAttributedStringKey.font: UIFont(name: "Gidole-Regular", size: 26)!]
        nav?.tintColor = UIColor(hex:"1B212C")
    }

    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
