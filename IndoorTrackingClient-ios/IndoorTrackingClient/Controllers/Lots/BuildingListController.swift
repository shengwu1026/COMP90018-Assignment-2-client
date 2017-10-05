//
//  BuildingListController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 29/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class BuildingListController: UITableViewController {
    
    private var buildings = [Building]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didTapAdd))
        tableView.separatorStyle = .none
        
        // Load all the lots.
        reloadBuildings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadBuildings()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoginCell") as? LoginTableViewCell else {
            fatalError("The dequeued cell was not the correct type: LoginTableViewCell")
        }
        
        cell.userLabel.text = "\(buildings[indexPath.row].name!)"
        //cell.detailTextLabel?.text = "\(buildings[indexPath.row].address.suburb), \(buildings[indexPath.row].address.city)"
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show a list of all the lots for this building.
        let selectedBuilding = self.buildings[indexPath.row]
        
        Lot.lotsForBuildingWithID(buildingID: selectedBuilding.id) { lots in
            let lotListController = LotListController()
            lotListController.lots = lots
            lotListController.building = selectedBuilding
            lotListController.title = "Lots in \(selectedBuilding.name!)"
            self.navigationController?.pushViewController(lotListController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Other
    // #####
    
    func didTapAdd() {
        let addController = AddBuildingController()
        addController.delegate = self
        self.present(addController, animated: true, completion: nil)
    }
    
    func reloadBuildings() {
        Building.all {
            self.gotBuildings(buildings: $0)
        }
    }
    
    private func gotBuildings(buildings: [Building]) {
        self.buildings = buildings
        self.tableView.reloadData()
    }
}

extension BuildingListController : FormDelegate {
    
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
        print("did submit with data: \(data)")
        
        // Building name
        let name = data["name"] ?? "Unknown"
        
        // Address
        let city = data["city"] ?? "Unknown"
        let state = data["state"] ?? "Unknown"
        let suburb = data["suburb"] ?? "Unknown"
        
        let streetName = data["street_name"] ?? "Unknown"
        let unitNumber = data["unit_number"] ?? "Unknown"
        let streetNumber = data["street_number"]  ?? "Unknown"
        
        let postCode = Int(data["post_code"]!) ?? 0
        
        let address = Address(city: city, state: state, suburb: suburb, streetName: streetName, unitNumber: unitNumber, streetNumber: streetNumber, postCode: postCode)
        
        Building.create(address: address, name: name, levels: []) { newBuilding in
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.reloadBuildings()
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
