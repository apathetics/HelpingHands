////
////  DatabaseHelper.swift
////  Helping Hands
////
////  Created by Tracy Nguyen on 3/21/18.
////  Copyright © 2018 Tracy Nguyen. All rights reserved.
////
//    UTILITY CLASS FOR LATER CLEAN UP (closures are not making this easy)
//
//import Foundation
//import FirebaseDatabase
//
//class DatabaseHelper {
//
//    //  EVENTS DATABASE RETRIEVAL
//    static func retrieveEvents(eventsList: inout [Event], table: UITableView) {
//
//        let databaseRef = FIRDatabase.database().reference(fromURL: "https://helping-hands-8f10c.firebaseio.com/")
//        let eventsRef = databaseRef.child("events")
//
//        eventsRef.observe(FIRDataEventType.value, with: {(snapshot) in
//
//            // make sure there are events
//            if snapshot.childrenCount > 0 {
//
//                // clear event list before appending again
//                eventsList.removeAll()
//
//                // for each snapshot (entity present under events child)
//                for eventSnapshot in snapshot.children.allObjects as! [FIRDataSnapshot] {
//
//                    let eventObject = eventSnapshot.value as! [String: AnyObject]
//                    let event = Event()
//
//                    event.address = eventObject["eventAddress"] as! String
//                    event.currentLocation = eventObject["eventCurrentLocation"] as! Bool
//                    event.eventDateString = eventObject["eventDate"] as! String
//                    event.eventDescription = eventObject["eventDescription"] as! String
//                    event.distance = eventObject["eventDistance"] as! Double
//
//                    // TODO: Image from URL?
//                    event.image = UIImage(named: "meeting")
//
//                    event.numHelpers = eventObject["eventNumHelpers"] as! Int
//                    event.eventTitle = eventObject["eventTitle"] as! String
//
//
//                    eventsList.append(event)
//
//                }
//            }
//        })
//    }
//
//}

