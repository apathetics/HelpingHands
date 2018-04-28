//
//  EventTableViewCell.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/13/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell, Themeable {
    
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var helpersLbl: UILabel!
    @IBOutlet weak var eventDescriptionLbl: UILabel!
    
    
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
        theme.applyBodyTextStyle(labels: [eventTitleLbl, eventDescriptionLbl])
    }
    
}

