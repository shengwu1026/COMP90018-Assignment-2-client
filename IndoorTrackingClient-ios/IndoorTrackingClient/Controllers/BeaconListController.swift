//
//  BeaconListController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 16/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconListController: UITableViewController {

    var locationManager: CLLocationManager!
    let proximityUUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")! // This is the default for our beacons.
    var detectedBeacons = [CLBeacon]()
    var currentLot: Lot?
    var haveSetup = false

    deinit {
        //print("did deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        self.tableView.separatorStyle = .none
        
        haveSetup = true
        
        startMonitoringBeaconRegion()
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detectedBeacons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Does this really dequeue or is it creating it every time?
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconInfoCell") as? BeaconInfoCell else {
            fatalError("The dequeued cell was not the correct type: BeaconInfoCell")
        }
        
        cell.beaconLabel?.text = "Major: \(detectedBeacons[indexPath.row].major), Minor: \(detectedBeacons[indexPath.row].minor)"
        cell.beaconDistanceLabel?.text = "Distance: \(detectedBeacons[indexPath.row].accuracy.rounded(toPlaces: 3)) metres"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentLot = currentLot {
            let selectedBeacon = detectedBeacons[indexPath.row]
            let addNewBeaconController = AddBeaconViewController(selectedBeacon: selectedBeacon, currentLot: currentLot)
            self.present(addNewBeaconController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension BeaconListController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        self.detectedBeacons = beacons
        self.tableView.reloadData()
    }
}


extension Double {
    // https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}






