//
//  ThemeVC.swift
//  Helping Hands
//
//  Created by Manasa Tipparam on 3/21/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation

class ThemeVC: UIViewController {
    
    var darkBlue: UIColor = UIColor(red: 27.0/255.0, green: 33.0/255.0, blue: 44.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayTheme()
        
    }
    
    func dayTheme() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : darkBlue]
        self.navigationController?.navigationBar.tintColor = darkBlue
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
