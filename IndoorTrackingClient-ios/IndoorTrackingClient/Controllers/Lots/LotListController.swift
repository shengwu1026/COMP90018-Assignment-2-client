//
//  LotListController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 16/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class LotListController: UITableViewController {
    
    var lots: [Lot]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return lots?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Does this really dequeue or is it creating it every time?
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if(cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        if let name = lots?[indexPath.row].name!, let width = lots?[indexPath.row].dimensions.width, let length = lots?[indexPath.row].dimensions.length {
            cell!.textLabel?.text = "\(name)"
            cell!.detailTextLabel?.text = "Width: \(width) Length: \(length)"
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Nothing for now.
    }
    
    // Other
    // #####
    
    func reloadLots() {
        // If there are no lots, default to all of them.
        if(lots == nil) {
            Lot.all {
                self.gotLots(lots: $0)
            }
        }
        else {
            self.tableView.reloadData()
        }
        
    }
    
    private func gotLots(lots: [Lot]) {
        self.lots = lots
        self.tableView.reloadData()
    }
}
