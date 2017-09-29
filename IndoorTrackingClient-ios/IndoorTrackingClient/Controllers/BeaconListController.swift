//
//  BeaconListController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 16/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconInfoCell : UITableViewCell {
    
    init() {
        super.init(style: .subtitle, reuseIdentifier: "BeaconInfoCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class BeaconListController: UITableViewController {

    var locationManager: CLLocationManager!
    let proximityUUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")! // This is the default for our beacons.
    var detectedBeacons = [CLBeacon]()
    var currentLot: Lot!
    var haveSetup = false

    deinit {
        print("did deinit")
    }
    
    init(currentLot: Lot) {
        self.currentLot = currentLot
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(BeaconInfoCell.self, forCellReuseIdentifier: "BeaconInfoCell")

        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        haveSetup = true
        
        startMonitoringBeaconRegion()
        self.title = "New Nearby Beacons"
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
        
        let cell = BeaconInfoCell()
        
        cell.textLabel?.text = "Major: \(detectedBeacons[indexPath.row].major)"
        cell.detailTextLabel?.text = "RSSI: \(detectedBeacons[indexPath.row].rssi)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBeacon = detectedBeacons[indexPath.row]
        let addNewBeaconController = AddBeaconViewController(selectedBeacon: selectedBeacon, currentLot: currentLot)
        self.present(addNewBeaconController, animated: true, completion: nil)
    }
}

extension BeaconListController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        self.detectedBeacons = beacons
        self.tableView.reloadData()
    }
}







