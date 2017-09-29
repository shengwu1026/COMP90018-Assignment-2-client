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

class AddBeaconViewController : FormViewController {
    
    var lot: Lot?
    var selectedBeacon: CLBeacon?
    fileprivate var formWasComplete = false
    
    init(selectedBeacon: CLBeacon, currentLot: Lot) {
        self.selectedBeacon = selectedBeacon
        self.lot = currentLot
        
        super.init(formTitle: "Add Beacon", sections: [])
        self.delegate = self
        self.sections = createSections()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createSections() -> [Section] {
        let beaconDetailSections = Section(name: "New Beacon")
        beaconDetailSections.addField(InputField(id: "lot_id", title: "Lot ID", isRequired: true))
        beaconDetailSections.addField(InputField(id: "manufacturer_uuid", title: "Beacon UUID", isRequired: true))
        beaconDetailSections.addField(InputField(id: "major", title: "Beacon Major", isRequired: true))
        beaconDetailSections.addField(InputField(id: "minor", title: "Beacon Minor", isRequired: true))
        beaconDetailSections.addField(InputField(id: "x", title: "x", isRequired: true))
        beaconDetailSections.addField(InputField(id: "y", title: "y", isRequired: true))
        return [beaconDetailSections]
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
                
                if let selectedBeacon = selectedBeacon, let lot = lot {
                    switch(field.id) {
                    case "lot_id":
                        cell.setDefaultValue(text: lot.id.uuidString)
                    case "manufacturer_uuid":
                        cell.setDefaultValue(text: selectedBeacon.proximityUUID.uuidString)
                    case "major":
                        cell.setDefaultValue(text: selectedBeacon.major.stringValue)
                    case "minor":
                        cell.setDefaultValue(text: selectedBeacon.minor.stringValue)
                    default:
                        break
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

extension AddBeaconViewController : FormDelegate {
    
    // Get a chance to do error checking here.
    func formShouldSubmitWithData(_ data: [String : String], complete: Bool, incompleteFieldIds: [String]?) -> Bool {
        
        if(!complete) {
            if let ids = incompleteFieldIds {
                shakeIncompleteFields(ids)
            }
            return false
        }
        
        // do more validation
        // if !validated, shake(), return false
        
        // We got to here, that means everything is complete and everything is validated, return true.
        return true
    }
    
    // Called only if formShouldSubmitWithData returns true. This is where we can use the data and dismiss, etc.
    func formDidSubmitWithData(_ data: [String : String]) {
        print("did submit with data: \(data)")
        
        // Create the beacon with the information.
        let manufacturerUUID = data["manufacturer_uuid"] ?? "unknown"
        let lotID = data["lot_id"] ?? "unknown"
        let major = Int(data["major"]!) ?? 0
        let minor = Int(data["minor"]!) ?? 0
        let x = Double(data["x"]!) ?? 0
        let y = Double(data["y"]!) ?? 0
        let beaconCoords = BeaconCoordinates(x: x, y: y)
        
        Beacon.create(lotID: UUID.init(uuidString: lotID)!, manufacturerUUID: UUID.init(uuidString: manufacturerUUID)!, major: major, minor: minor, coordinates: beaconCoords) { newBeacon in
            print(newBeacon)
        }
        
        self.mostRecentActiveCell?.dropFocus() // Get rid of the keyboard.
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // TODO: Implement highlighting and moving between form inputs
    // TODO: Implement keyboard and form relocation.
    func willMoveToNextInput(_ next: InputField) {
        // Nothing to do yet.
    }
    
    fileprivate func shakeIncompleteFields(_ fieldIds: [String]) {
        for fieldId in fieldIds {
            
            if let cell = self.cellForFieldId(fieldId) {
                cell.contentView.frame.origin.x = -50
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8, options: UIViewAnimationOptions.curveEaseOut, animations: { cell.contentView.frame.origin.x = 0 }, completion: nil)
            }
        }
    }
}
