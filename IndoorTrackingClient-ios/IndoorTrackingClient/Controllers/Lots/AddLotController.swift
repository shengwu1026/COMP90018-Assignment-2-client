//
//  AddBeaconController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 29/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import CoreBluetooth

class AddLotController : FormViewController {
    
    fileprivate var building: Building?
    fileprivate var formWasComplete = false
    
    init(building: Building) {
        self.building = building
        super.init(formTitle: "Add Lot", sections: [])
        self.sections = createSections()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createSections() -> [Section] {
        let lotSection = Section(name: "Lot")
        lotSection.addField(InputField(id: "building_id", title: "Building ID", isRequired: true))
        lotSection.addField(InputField(id: "lot_type", title: "Lot Type", isRequired: true))
        lotSection.addField(InputField(id: "name", title: "Name", isRequired: true))
        lotSection.addField(InputField(id: "floor_level", title: "Level", isRequired: true))
        
        let dimensionsSection = Section(name: "Dimensions")
        dimensionsSection.addField(InputField(id: "units", title: "Units", isRequired: true))
        dimensionsSection.addField(InputField(id: "width", title: "Width", isRequired: true))
        dimensionsSection.addField(InputField(id: "height", title: "Height", isRequired: true))
        dimensionsSection.addField(InputField(id: "length", title: "Length", isRequired: true))
        
        let beaconInfoSection = Section(name: "Beacon Info")
        beaconInfoSection.addField(InputField(id: "rssi_1m_away_from_beacon", title: "1M RSSI", isRequired: true))
        beaconInfoSection.addField(InputField(id: "average_phone_height", title: "Phone Height", isRequired: true))
        beaconInfoSection.addField(InputField(id: "path_loss", title: "Path Loss", isRequired: true))
        
        return [lotSection, dimensionsSection, beaconInfoSection]
    }
    
    override func didTapLeftButton() {
        self.mostRecentActiveCell?.dropFocus() // Get rid of the keyboard.
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func didTapRightButton() {
        self.submit()
    }
    
    // Want to create a set amount of cells and reuse these cells so that we can get the information entered into them by the user.
    override func createTableViewCells() {
        
        let cellBackgroundColor = Theme.currentTheme.colorForKey("global.input.cellBackgroundColor") ?? UIColor.white
        
        cells = [[FormInputCell]]()
        
        // For every section
        for section in sections {
            var sectionCells = [FormInputCell]()
            
            // Add an input field for every field in that section
            for field in section.fields {
                let cell = FormInputCell()
                cell.delegate = self
                cell.backgroundColor = cellBackgroundColor.withAlphaComponent(0.25)
                
                cell.id = field.id
                
                if let name = field.title {
                    cell.name = name
                }
                
                if let building = building {
                    switch(field.id) {
                    case "building_id":
                        cell.setDefaultValue(text: building.id.uuidString)
                    case "units":
                        cell.setDefaultValue(text: "metres")
                    case "average_phone_height":
                        cell.setDefaultValue(text: "1")
                    default: break
                    }
                    
                }
                
                if field.isRequired {
                    cell.placeholder = "Required"
                }
                
                cell.selectionStyle = .none
                
                sectionCells.append(cell)
            }
            
            cells.append(sectionCells)
        }
    }
}

