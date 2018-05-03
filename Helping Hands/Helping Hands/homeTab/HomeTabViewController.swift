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
import UserNotifications

class HomeTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, radiusDelegate, Themeable {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    
    var currentLocation: CLLocation?
    var jobs = [Job]()
    var chosen: Int?
    
    var loadingView: UIView = UIView()
    var activityIndicatorView: NVActivityIndicatorView!
    var errorLBL: UILabel!
    var errorView:UIView?
    
    let manager = CLLocationManager()
    let databaseRef = FIRDatabase.database().reference(fromURL: "https://helpinghands-presentation.firebaseio.com/")

    var radius = 0
    
    let notificationDelegate = NotificationDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow, error) in
        }
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate

        // Do any additional setup after loading the view, typically from a nib.
        ThemeService.shared.addThemeable(themable: self)
        
        // Reveal side menu toggle.
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // This check is not working for some reason.
        
//        // If not populated, then loading animation.
//        if(table.visibleCells.count > 0) {
//            activityIndicatorView.stopAnimating()
//            loadingView.isHidden = true
//        } else {
//            loadingView.isHidden = false
//        }
        
        print("JOB COUNT: \(jobs.count)\n\n")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        radius = UserDefaults.standard.value(forKey:"max_radius") as! Int
        
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
        
        self.activityIndicatorView.stopAnimating()
        self.loadingView.isHidden = true
        self.errorView?.isHidden = true
        
        // enableBasicLocationServices
        enableBasicLocationServices()
    }
    
    // Location delegate callback to make sure there IS an actual location or else it's nil.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[locations.count-1]
        self.retrieveJobs()
    }
    
    // asynchronously determines whether or not changes to location settings have been made and responds
    // by asking user to turn them back on for the app.
    func enableBasicLocationServices() {
        manager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            disableMyLocationBasedFeatures()
            manager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            enableMyWhenInUseFeatures()
            break
        }
    }
    
    // Prevents Location Features from being called, asks user to enable them
    func disableMyLocationBasedFeatures() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let SWRController: EnableLocationViewController = storyboard.instantiateViewController(withIdentifier: "allowLocationPls") as! EnableLocationViewController
        self.present(SWRController, animated: true, completion: nil)
    }
    
    // Enables Location Features
    func enableMyWhenInUseFeatures() {
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        manager.startUpdatingLocation()
        
        if(self.currentLocation != nil) {
            self.retrieveJobs()
        }
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
        table.deselectRow(at: indexPath, animated: true)
    }
    
    // FIREBASE RETRIEVAL
    @objc func retrieveJobs() {
        //jobs.removeAll()
        let jobsRef = databaseRef.child("jobs")
        
        jobsRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            // make sure there are jobs
            if snapshot.childrenCount > 0 {
                self.table.isHidden = false
                print("There are job snapshots!!")
                // for each snapshot (entity present under jobs child)
                for jobSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if(self.containsJobWithId(id: jobSnapshot.ref.key)) {
                        // job already in list
                    } else {
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
                        
                        let locationManager = self.manager
                        locationManager.delegate = self
                        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                        locationManager.requestAlwaysAuthorization()
                        locationManager.startUpdatingLocation()
                        
                        let distance = locationManager.location!.distance(from: CLLocation(latitude: job.latitude, longitude: job.longitude)) * 0.00062137
                        job.distance = distance
                        
                        if (job.distance <= Double(self.radius))
                        {
                            self.jobs.append(job)
                            self.jobs = self.jobs.sorted(by: { $0.distance < $1.distance })
                            self.activityIndicatorView.stopAnimating()
                            self.loadingView.isHidden = true
                            for view in self.loadingView.subviews {
                                view.removeFromSuperview()
                            }
                            self.errorView?.isHidden = true
                        }
                        
                        self.jobs = self.jobs.filter {
                            result in return (result.distance <= Double(self.radius))
                        }
                        
                        // Check if there are jobs and if not, show loading screen.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if (self.jobs.count == 0) {
                                self.activityIndicatorView.stopAnimating()
                                self.loadingView.isHidden = false
//                                var frame = CGRect(x: self.loadingView.bounds.size.width*0.5 - 90, y: self.loadingView.bounds.size.height*0.5 - 175, width: 180, height: 350)
//                                self.errorView = UIView(frame: frame)
//                                let size = CGSize(width: 180, height: 350)
//                                let errorGraphic = UIImageView(image: UIImage(named: "nojobs")?.scaleImageToSize(newSize: size))
//                                self.errorView!.addSubview(errorGraphic)
//                                frame = CGRect(x: self.loadingView.bounds.size.width*0.5 - 90, y: self.loadingView.bounds.size.height*0.5 + 180, width: 180, height: 50)
//                                self.errorLBL = UILabel(frame: frame)
//                                self.errorLBL.lineBreakMode = .byWordWrapping
//                                self.errorLBL.numberOfLines = 0
//                                self.errorLBL.textAlignment = .center
//                                self.errorLBL.text = "There are currently no jobs in this area :("
//                                self.errorLBL.font = UIFont(name: "Gidole-Regular", size: 20)
//                                self.errorLBL.textColor = UIColor(hex:"2b3445")
//                                self.loadingView.addSubview(self.errorView!)
//                                self.loadingView.addSubview(self.errorLBL)
                            }

//                            if(self.jobs.count > 0) {
//                                self.activityIndicatorView.stopAnimating()
//                                self.loadingView.isHidden = true
//                            }

                        }
                        
                        
                        self.table.reloadData()
                    }
                }
            }
            
        })
    }
    
    func containsJobWithId(id: String) -> Bool{
        for j in jobs {
            if j.jobId == id {
                return true
            }
        }
        return false
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
    
    // Used to update list when user changes radius settings
    func sendRadius(radius: Int) {
        print("will refresh")
        self.radius = radius
        retrieveJobs()
    }

}

