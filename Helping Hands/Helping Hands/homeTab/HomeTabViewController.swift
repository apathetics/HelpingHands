//
//  HomeTabViewController.swift
//  Helping Hands
//
//  Created by Tracy Nguyen on 2/28/18.
//  Copyright © 2018 Tracy Nguyen. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import FirebaseDatabase
import FirebaseStorageUI
import NVActivityIndicatorView

class HomeTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, Themeable {
    
    let manager = CLLocationManager()
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    var jobs = [Job]()
    var chosen: Int?
    
    var loadingView: UIView!
    var activityIndicatorView: NVActivityIndicatorView!
    var errorLBL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ThemeService.shared.addThemeable(themable: self)
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Location permissions
        manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            manager.startUpdatingLocation()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.isHidden = true
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(loadingView)
        let frame = CGRect(x: screenWidth*0.5 - 30, y: screenHeight*0.5 - 30, width: 60, height: 60)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.circleStrokeSpin.rawValue))
        activityIndicatorView.color = UIColor(hex:"2b3445")
        loadingView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        retrieveJobs()
    }
    
    //  ** PREPARE SEGUES ** \\
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addJob") {
            let addJobVC:AddJobViewController = segue.destination as! AddJobViewController
            addJobVC.masterView = self
        }
        
        if(segue.identifier == "showJob") {
            let j:Job = jobs[chosen!]
            let jobVC:JobViewController = segue.destination as! JobViewController
            jobVC.job = j
            jobVC.jobID = j.jobId
        }
    }
    
    // ** START TABLE FUNCTIONS ** \\
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:JobTableViewCell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobTableViewCell
        
        let row = indexPath.row
        let j:Job = jobs[row]
        
        cell.jobTitleLbl.text = j.jobTitle
        cell.jobDescriptionLbl.text = j.jobDescription
        cell.distanceLbl.text = String(format: "%.2f", j.distance) + " mi"
        let ftmPayment = "$" + ((j.payment).truncatingRemainder(dividingBy: 1) == 0 ? String(j.payment) : String(j.payment))
        cell.paymentLbl.text = j.isHourlyPaid == true ? ftmPayment + "/hr" : ftmPayment
        
        // Placeholder image
        let placeholderImage = UIImage(named: "meeting")
        // Load the image using SDWebImage
        cell.jobImg.sd_setImage(with: URL(string: j.imageAsString), placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        cell.jobImg.layer.cornerRadius = 6.0
        cell.jobImg.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if(!table.visibleCells.isEmpty) {
            activityIndicatorView.stopAnimating()
            loadingView.isHidden = true
            table.isHidden = false
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosen = (indexPath.row)
        self.performSegue(withIdentifier: "showJob", sender: self)
    }
    
    // FIREBASE RETRIEVAL
    @objc func retrieveJobs() {
        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands3-fb14f.firebaseio.com/")
        let jobsRef = databaseRef.child("jobs")
        
        jobsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                // clear job list before appending again
                self.jobs.removeAll()
                
                // for each snapshot (entity present under jobs child)
                for jobSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    
                    // retrieve jobs and append to job list after creation
                    let jobObject = jobSnapshot.value as! [String: AnyObject]
                    let job = Job()
                    
                    job.address = jobObject["jobAddress"] as! String
                    job.currentLocation = jobObject["jobCurrentLocation"] as! Bool
                    job.jobDateString = jobObject["jobDate"] as! String
                    job.jobDescription = jobObject["jobDescription"] as! String
                    job.distance = jobObject["jobDistance"] as! Double
                    job.imageAsString = jobObject["jobImageUrl"] as! String
                    job.isHourlyPaid = jobObject["jobIsHourlyPaid"] as! Bool
                    job.numHelpers = jobObject["jobNumHelpers"] as! Int
                    job.payment = jobObject["jobPayment"] as! Double
                    job.jobTitle = jobObject["jobTitle"] as! String
                    job.jobId = jobSnapshot.ref.key
                    if(jobObject["latitude"] == nil)
                    {
                        job.latitude = 0
                        job.longitude = 0
                    }
                    else {
                        job.latitude = jobObject["latitude"] as! Double
                        job.longitude = jobObject["longitude"] as! Double
                    }
                    
                    let locationManager = CLLocationManager()
                    locationManager.delegate = self;
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                    let distance = (locationManager.location?.distance(from: CLLocation(latitude: job.latitude, longitude: job.longitude)) as! Double) * 0.00062137
                    job.distance = distance
                    
                    if (job.distance <= UserDefaults.standard.value(forKey:"max_radius") as! Double)
                    {
                        self.jobs.append(job)
                        self.jobs = self.jobs.sorted(by: { $0.distance < $1.distance })
                    }

                    self.table.reloadData()
                }
            }
        })
        if (table.visibleCells.count == 0) {
            usleep(1500000) // sleep .5 seconds
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
            var frame = CGRect(x: loadingView.bounds.size.width*0.5 - 90, y: loadingView.bounds.size.height*0.5 - 175, width: 180, height: 350)
            let errorView = UIView(frame: frame)
            let size = CGSize(width: 180, height: 350)
            let errorGraphic = UIImageView(image: UIImage(named: "nojobs")?.scaleImageToSize(newSize: size))
            errorView.addSubview(errorGraphic)
            frame = CGRect(x: loadingView.bounds.size.width*0.5 - 90, y: loadingView.bounds.size.height*0.5 + 180, width: 180, height: 50)
            errorLBL = UILabel(frame: frame)
            errorLBL.lineBreakMode = .byWordWrapping
            errorLBL.numberOfLines = 0
            errorLBL.textAlignment = .center
            errorLBL.text = "There are currently no jobs in this area :("
            errorLBL.font = UIFont(name: "Gidole-Regular", size: 20)
            errorLBL.textColor = UIColor(hex:"2b3445")
            loadingView.addSubview(errorView)
            loadingView.addSubview(errorLBL)

        }
    }
    
    
    func applyTheme(theme: Theme) {
        theme.applyBackgroundColor(views: [view])
        theme.applyTabBarTintColor(tabBar: self.tabBarController!)
        theme.applyNavBarTintColor(navBar: self.navigationController!)
        theme.applyTintColor_Font(navBar: self.navigationController!)
        theme.applyTableViewBackgroundColor(tableView: [table])
        for cell in table.visibleCells {
            theme.applyBodyTextStyle(labels: [ ((cell as! JobTableViewCell).jobDescriptionLbl!) ])
            theme.applyHeadlineStyle(labels: [ ((cell as! JobTableViewCell).jobTitleLbl!) ])
        }
    }

}

