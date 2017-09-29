//
//  LotListController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 16/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class LotListController: UITableViewController {
    
    var lots = [Lot]()
    var building: Building?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didTapAdd))
        
        // Reload the table.
        reloadLots()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadLots()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lots.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Does this really dequeue or is it creating it every time?
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if(cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        let name = lots[indexPath.row].name!
        let width = lots[indexPath.row].dimensions.width
        let length = lots[indexPath.row].dimensions.length
        cell!.textLabel?.text = "\(name)"
        cell!.detailTextLabel?.text = "Width: \(width) Length: \(length)"
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLot = lots[indexPath.row]
        let nearbyBeaconsList = BeaconListController(currentLot: selectedLot)
        
        self.navigationController?.pushViewController(nearbyBeaconsList, animated: true)
    }
    
    // Other
    // #####
    
    func didTapAdd() {
        if let building = building {
            let addController = AddLotController(building: building)
            addController.delegate = self
            self.present(addController, animated: true, completion: nil)
        }
    }
    
    func reloadLots() {
        if let building = building {
            Lot.lotsForBuildingWithID(buildingID: building.id) { lots in
                self.gotLots(lots: lots)
            }
        }
    }
    
    private func gotLots(lots: [Lot]) {
        self.lots = lots
        self.tableView.reloadData()
    }
}

extension LotListController : FormDelegate {
    
    // Get a chance to do error checking here.
    func formShouldSubmitWithData(_ data: [String : String], complete: Bool, incompleteFieldIds: [String]?) -> Bool {
        
        if(!complete) {
            if let ids = incompleteFieldIds {
                shakeIncompleteFields(ids)
            }
            return false
        }
        
        return true
    }
    
    func formDidSubmitWithData(_ data: [String : String]) {
        
        // building_id
        let buildingId = data["building_id"] ?? "Unknown"
        let lotType = data["lot_type"] ?? "Unknown"
        let name = data["name"] ?? "Unknown"
        let floorLevel = Int(data["floor_level"]!) ?? 0
        
        let units = data["units"] ?? "Metres"
        let width = Double(data["width"]!) ?? 0
        let height = Double(data["height"]!) ?? 0
        let length = Double(data["length"]!) ?? 0
        
        let dimensions = LotDimensions(units: units, width: width, height: height, length: length)
        
        let rssi1m = Int(data["rssi_1m_away_from_beacon"]!) ?? 0
        let phoneHeight = Double(data["average_phone_height"]!) ?? 0
        let pathLoss = Double(data["path_loss"]!) ?? 0
        
        Lot.create(buildingID: UUID.init(uuidString: buildingId)!, lotType: lotType, name: name, floorLevel: floorLevel, dimensions: dimensions, rssi1m: rssi1m, phoneHeight: phoneHeight, pathLoss: pathLoss) { newLot in
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.reloadLots()
        }
    }
    
    func willMoveToNextInput(_ next: InputField) {
        // Nothing to do yet.
    }
    
    fileprivate func shakeIncompleteFields(_ fieldIds: [String]) {
        for fieldId in fieldIds {
            if let viewController = self.presentedViewController as? FormViewController {
                if let cell = viewController.cellForFieldId(fieldId) {
                    cell.contentView.frame.origin.x = -50
                    UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8, options: UIViewAnimationOptions.curveEaseOut, animations: { cell.contentView.frame.origin.x = 0 }, completion: nil)
                }
            }
        }
    }
}
