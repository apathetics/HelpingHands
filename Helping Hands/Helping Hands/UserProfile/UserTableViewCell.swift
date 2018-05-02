//
//  UserTableViewCell.swift
//  Helping Hands
//
//  Created by Bryan Bernal on 3/18/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell, Themeable {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func applyTheme(theme: Theme) {
        theme.applyBodyTextStyle(labels: [userName])
    }
}

