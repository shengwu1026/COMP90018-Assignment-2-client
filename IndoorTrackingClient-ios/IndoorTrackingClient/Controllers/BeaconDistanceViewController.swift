//
//  BeaconDistanceViewController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 12/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class BeaconDistanceViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        startMonitoringBeaconRegion()
    }
    
    func startMonitoringBeaconRegion() {
    
        print("did start monitoring beacon region")
        
        let beaconUUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: "darkBlue")
        
        locationManager.startMonitoring(for: beaconRegion)
        
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        print("Did range beacons")
        print("Number of beacons: \(beacons.count)")
        
        guard beacons.count > 0 else {
            return
        }
        
        for beacon in beacons {
            print("UUID: \(beacon.proximityUUID)")
            print("Major: \(beacon.major)")
            print("Minor: \(beacon.minor)")
            print("RSSI: \(beacon.rssi)")
            print("##################")
        }
        
        let closestBeacon = beacons[0]
        print(closestBeacon.rssi)
    }
}
