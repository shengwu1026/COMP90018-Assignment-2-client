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
}

class TrackerViewController : UIViewController {
  
    // when this view becomes active
    
        // we get the three strongest beacons
    
        // triangulate with these once every second
    
        // this continues in the background
    
    var mapView = LocationView()
    
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
        
        self.view.backgroundColor = UIColor.white
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        haveSetup = true
        
        startMonitoringBeaconRegion()
        self.title = "TRACKER"
        
        setupMapView()
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
            
            let newBeaconInfo = LocalBeaconInfo(uuid: uuid, major: major, minor: minor, rssi: rssi)
            beaconInfo.append(newBeaconInfo)
        }
        
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
    }
    
    private func setupMapView() {
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = constraintsToContainViewVertically(mapView, inContainingView: self.view)
        constraints += constraintsToContainViewHorizontally(mapView, inContainingView: self.view)
        
        self.view.addSubview(mapView)
        self.view.addConstraints(constraints)
    }
}

extension TrackerViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Ranged beacons.")
        self.detectedBeacons = beacons
    }
}







