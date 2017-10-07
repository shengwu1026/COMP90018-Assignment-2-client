//
//  TrackerViewController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 29/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct LocalBeaconInfo {
    var uuid: UUID
    var major: Int
    var minor: Int
    var rssi: Int
    var distance: Double
}

class TrackerViewController : UIViewController {
  
    @IBOutlet weak var usersImageView: UIImageView!
    @IBOutlet weak var buildingsImageView: UIImageView!
    
    //var mapView: LocationView!
    
    // when this view becomes active
    
        // we get the three strongest beacons
    
        // triangulate with these once every second
    
        // this continues in the background
    
    //var mapView = LocationView()
    
    var locationManager: CLLocationManager!
    let proximityUUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")! // This is the default for our beacons.

    var haveSetup = false
    
    var detectedBeacons = [CLBeacon]() {
        didSet {
            if detectedBeacons.count >= 3 {
                triangulate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        haveSetup = true
        
        startMonitoringBeaconRegion()
        self.title = "TRACKER"
        
        setupTapGestures()
        // setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(haveSetup) {
            startMonitoringBeaconRegion()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopMonitoringBeaconRegion()
    }
    
    private func startMonitoringBeaconRegion() {
        let beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, identifier: "LocationBeacons")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    private func stopMonitoringBeaconRegion() {
        let beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, identifier: "LocationBeacons")
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    private func triangulate() {
        
        guard let currentUser = UserSettings.shared.currentUser else {
            return
        }
        
        var beaconInfo = [LocalBeaconInfo]()
        
        for detectedBeacon in detectedBeacons {
            
            let uuid = detectedBeacon.proximityUUID
            let major = detectedBeacon.major.intValue
            let minor = detectedBeacon.minor.intValue
            let rssi = detectedBeacon.rssi
            let distance = detectedBeacon.accuracy
            
            print("distance to \(major): " + detectedBeacon.accuracy.description)
            
            let newBeaconInfo = LocalBeaconInfo(uuid: uuid, major: major, minor: minor, rssi: rssi, distance: distance)
            beaconInfo.append(newBeaconInfo)
        }
        
        
        let beaconLocations = [63689 : (x: -2.98, y: 1.64), 22175 : (x: 0, y: 0), 54350 : (x: 2.48, y: -2.2)]
        
        let x0 = beaconLocations[beaconInfo[0].major]!.x
        let y0 = beaconLocations[beaconInfo[0].major]!.y
        let r0 = beaconInfo[0].distance
        
        let x1 = beaconLocations[beaconInfo[1].major]!.x
        let y1 = beaconLocations[beaconInfo[1].major]!.y
        let r1 = beaconInfo[1].distance
        
        let x2 = beaconLocations[beaconInfo[2].major]!.x
        let y2 = beaconLocations[beaconInfo[2].major]!.y
        let r2 = beaconInfo[2].distance
        
        
        if let intersection = LocationHelper.triangulate(x0: x0, y0: y0, r0: r0, x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2) { // lol
            print(intersection)
            
            //self.mapView.setPositions(positions: [CGPoint(x: intersection.x * 100, y: intersection.y * 100)])
            
            currentUser.updateLocation(beaconInfo: beaconInfo, coordinates: CGPoint(x: intersection.x, y: intersection.y)) { result in
                print(result)
            }
            
        }
        
        // Use the server to triangulate
        /*
        currentUser.triangulate(beaconInfo: beaconInfo) { success in
            let message = success ? "Successfully triangulated." : "Unable to triangulate."
            print(message)
            
            if(success) {
                currentUser.location() { (x, y) in
                    print("x: \(x)")
                    print("y: \(y)")
                    
                    self.mapView.setPositions(positions: [CGPoint(x: x, y: y)])
                }
            }
        }
         */
    }
    
    /*
    private func setupMapView() {
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = constraintsToContainViewVertically(mapView, inContainingView: self.view)
        constraints += constraintsToContainViewHorizontally(mapView, inContainingView: self.view)
        
        self.view.addSubview(mapView)
        self.view.addConstraints(constraints)
    }
    */
    
    private func setupTapGestures() {
        
        usersImageView.isUserInteractionEnabled = true
        buildingsImageView.isUserInteractionEnabled = true
        
        let userTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUsers))
        usersImageView.addGestureRecognizer(userTapGesture)
        
        let buildingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBuildings))
        buildingsImageView.addGestureRecognizer(buildingsTapGesture)
    }
    
    func didTapUsers() {
        performSegue(withIdentifier: "ShowUsers", sender: self)
    }
    
    func didTapBuildings() {
        performSegue(withIdentifier: "ShowBuildings", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let ident = segue.identifier else {
            return
        }
        
        switch (ident) {
        case "ShowUsers":
            if let users = segue.destination as? UserListController {
                // prepare for users.
            }
        case "ShowBuildings":
            if let buildings = segue.destination as? BuildingListController {
                // prepare for users.
            }
        default:
            //do nothing
            break
        }
    }
}

extension TrackerViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Ranged beacons.")
        self.detectedBeacons = beacons
    }
}

class LocationHelper {
    
    static func triangulate(x0: Double, y0: Double, r0: Double, x1: Double, y1: Double, r1: Double, x2: Double, y2: Double, r2: Double) -> (x: Double, y: Double)? {
        
        var r0 = r0
        var r1 = r1
        
        
        var a: Double = 0
        var dx: Double = 0
        var dy: Double = 0
        var d: Double = 0
        var h: Double = 0
        var rx: Double = 0
        var ry: Double = 0
        
        var point2_x: Double = 0
        var point2_y: Double = 0
        
        let EPSILON = 5.0
        let INCREMENT = 0.2
        
        /* dx and dy are the vertical and horizontal distances between
         * the circle centers.
         */
        dx = x1 - x0
        dy = y1 - y0
        
        /* Determine the straight-line distance between the centers. */
        d = sqrt((dy*dy) + (dx*dx))
        
        var r0sTurnToGrow = true
        
        /* Check for solvability. */
        while (d > (r0 + r1))
        {
            if (r0sTurnToGrow) {
                r0 += INCREMENT
                r0sTurnToGrow = !r0sTurnToGrow
            }
            else {
                r1 += INCREMENT
                r0sTurnToGrow = !r0sTurnToGrow
            }
            
            /* no solution. circles do not intersect. */
            //print("no intersection")
            //return nil
        }
        
        while (d < abs(r0 - r1))
        {
            if(r0 > r1) {
                r0 -= INCREMENT
            }
            else {
                r1 -= INCREMENT
            }
            
            /* no solution. one circle is contained in the other */
            //print("circle is contained in another")
            //return nil
        }
        
        /* 'point 2' is the point where the line through the circle
         * intersection points crosses the line between the circle
         * centers.
         */
        
        /* Determine the distance from point 0 to point 2. */
        a = ((r0*r0) - (r1*r1) + (d*d)) / (2.0 * d)
        
        /* Determine the coordinates of point 2. */
        point2_x = x0 + (dx * a/d)
        point2_y = y0 + (dy * a/d)
        
        /* Determine the distance from point 2 to either of the
         * intersection points.
         */
        print((r0*r0) - (a*a))
        h = sqrt((r0*r0) - (a*a))
        
        /* Now determine the offsets of the intersection points from
         * point 2.
         */
        rx = -dy * (h/d)
        ry = dx * (h/d)
        
        /* Determine the absolute intersection points. */
        var intersectionPoint1_x: Double = point2_x + rx
        var intersectionPoint2_x: Double = point2_x - rx
        var intersectionPoint1_y: Double = point2_y + ry
        var intersectionPoint2_y: Double = point2_y - ry
        
        //print("INTERSECTION Circle1 AND Circle2:" + "(" + intersectionPoint1_x + "," + intersectionPoint1_y + ")" + " AND (" + intersectionPoint2_x + "," + intersectionPoint2_y + ")")
        
        /* Lets determine if circle 3 intersects at either of the above intersection points. */
        dx = intersectionPoint1_x - x2
        dy = intersectionPoint1_y - y2
        var d1: Double = sqrt((dy*dy) + (dx*dx))
        
        dx = intersectionPoint2_x - x2
        dy = intersectionPoint2_y - y2
        var d2: Double = sqrt((dy*dy) + (dx*dx))
        
        print(abs(d1-r2))
        print(abs(d2-r2))
        
        if(abs(d1 - r2) < EPSILON) {
            return (x: intersectionPoint1_x, y: intersectionPoint1_y)
        }
        else if(abs(d2 - r2) < EPSILON) {
            return (x: intersectionPoint2_x, y: intersectionPoint2_y)
        }
        else {
            return nil
        }
        
        return nil
    }
}







