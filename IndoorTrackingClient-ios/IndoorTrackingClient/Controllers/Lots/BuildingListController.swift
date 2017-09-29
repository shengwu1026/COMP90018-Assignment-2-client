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
        
        // Load all the lots.
        reloadBuildings()
        self.title = "All Buildings"
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
        
        // Does this really dequeue or is it creating it every time?
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if(cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell!.textLabel?.text = "\(buildings[indexPath.row].name!)"
        cell!.detailTextLabel?.text = "\(buildings[indexPath.row].address.suburb), \(buildings[indexPath.row].address.city)"
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show a list of all the lots for this building.
        let selectedBuilding = self.buildings[indexPath.row]
        Lot.lotsForBuildingWithID(buildingID: selectedBuilding.id) { lots in
            let lotListController = LotListController()
            lotListController.lots = lots
            lotListController.title = "Lots in \(selectedBuilding.name!)"
            self.navigationController?.pushViewController(lotListController, animated: true)
        }
    }
    
    // Other
    // #####
    
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
