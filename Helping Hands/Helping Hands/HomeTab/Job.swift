//
//  Job.swift
//  Helping Hands
//
//  Created by Ozone Kafley on 3/13/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit

class Job {
    var jobTitle:String!
    var jobDescription:String!
    var distance:Double!
    var image:UIImage!
    var payment:Double!
    var isHourlyPaid:Bool! // could be total, hourly, etc.
    var date:Date!
    var address:String!
    var currentLocation:Bool!
    var numHelpers:Int!
    var jobDateString: String!
}
