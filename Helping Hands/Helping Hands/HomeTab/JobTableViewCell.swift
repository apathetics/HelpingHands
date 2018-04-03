//
//  JobTableViewCell.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/13/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {

    @IBOutlet weak var jobImg: UIImageView!
    
    @IBOutlet weak var jobTitleLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var jobDescriptionLbl: UILabel!
    @IBOutlet weak var paymentLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
