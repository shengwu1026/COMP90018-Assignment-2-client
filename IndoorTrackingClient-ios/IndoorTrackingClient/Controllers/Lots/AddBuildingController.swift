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

class AddBuildingController : FormViewController {
    
    fileprivate var formWasComplete = false
    
    init() {
        super.init(formTitle: "Add Building", sections: [])
        self.sections = createSections()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createSections() -> [Section] {
        
        let buildingSection = Section(name: "Building")
        buildingSection.addField(InputField(id: "name", title: "Name", isRequired: true))
        
        let addressSection = Section(name: "Address")
        addressSection.addField(InputField(id: "unit_number", title: "Unit #", isRequired: true))
        addressSection.addField(InputField(id: "street_name", title: "Street", isRequired: true))
        addressSection.addField(InputField(id: "street_number", title: "Street #", isRequired: true))
        addressSection.addField(InputField(id: "suburb", title: "Suburb", isRequired: true))
        addressSection.addField(InputField(id: "city", title: "City", isRequired: true))
        addressSection.addField(InputField(id: "state", title: "State", isRequired: true))
        addressSection.addField(InputField(id: "post_code", title: "Postcode", isRequired: true))
        
        return [buildingSection, addressSection]
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

