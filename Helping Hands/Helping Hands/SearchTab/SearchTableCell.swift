//
//  searchTableCell.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 3/17/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class SearchTableCell: UITableViewCell, Themeable {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var typeResult:String?
    
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
        theme.applyBodyTextStyle(labels: [distanceLabel])
        theme.applyBackgroundColor(views: [picture])
        theme.applyHeadlineStyle(labels: [jobTitleLabel, descriptionLabel])
    }
}
