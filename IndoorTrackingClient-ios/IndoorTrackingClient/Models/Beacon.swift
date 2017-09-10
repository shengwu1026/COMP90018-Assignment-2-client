//
//  Beacon.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 9/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation

enum BeaconType {
    case edge
    case normal
}

struct BeaconCoordinates {
    var x: Double
    var y: Double
}

class Beacon {
    
    var lotID: UUID!
    var manufacturerUUID: UUID!
    var beaconType: BeaconType!
    var coordinates: BeaconCoordinates!
    var lastActivity: Date!
    
    // Create the beacon object from a JSON string.
    init?(jsonString: String) {
        
        if let jsonData = jsonString.data(using: .utf8) {
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
                
                // If we can convert the object to a dict
                if let jsonDict = jsonObject as? [String:Any] {
                    
                    // get the individual values
                    
                    // lotID
                    if let id = jsonDict["lot_id"] as? String {
                        lotID = UUID.init(uuidString: id)!
                    }
                    
                    // manufacturerUUID
                    if let id = jsonDict["manufacturer_uuid"] as? String {
                        manufacturerUUID = UUID.init(uuidString: id)!
                    }
                    
                    // beaconType
                    if let beaconType = jsonDict["lot_id"] as? String {
                        switch(beaconType) {
                        case "Edge":
                            self.beaconType = .edge
                        case "Normal":
                            self.beaconType = .normal
                        default:
                            self.beaconType = .edge
                        }
                    }
                    
                    // coordinates
                    if let coords = jsonDict["coordinates"] as? [String:Any] {
                        if let x = coords["x"] as? Double, let y = coords["y"] as? Double {
                            self.coordinates = BeaconCoordinates(x: x, y: y)
                        }
                    }
                    
                    // lastActivity
                    if let date = jsonDict["last_activity"] as? String {
                        
                        lastActivity = Date()
                        
                        // TODO: figure out the proper date format for the date string being returned from the server.
                        /*
                        // 2017-09-09T10:23:04.301+10:00
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd’T’HH:mm:ss.SSSXXXXX"
                        
                        let lastActivityFromString = formatter.date(from: date)
                        lastActivity = lastActivityFromString!
                         */
                    }
                }
            }
            catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
    }
    
    static func create(lotID: UUID, manufacturerUUID: UUID, beaconType: BeaconType, coordinates: BeaconCoordinates, lastActivity: Date) {
        
        
        // 1: create on server
        
        // 2: with ok response, complete completion handler, pass in the new beacon object.
        
    }
    
    
}
