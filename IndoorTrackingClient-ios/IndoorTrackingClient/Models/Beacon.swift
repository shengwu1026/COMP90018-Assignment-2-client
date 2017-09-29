//
//  Beacon.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 9/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import Alamofire

enum BeaconType {
    case edge
    case normal
}

struct BeaconCoordinates {
    var x: Double
    var y: Double
}

class Beacon {
    
    var id: UUID!
    var lotID: UUID!
    var manufacturerUUID: UUID!
    var major: Int!
    var minor: Int!
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
                    // beacon id
                    if let beaconID = jsonDict["id"] as? String {
                        self.id = UUID.init(uuidString: beaconID)
                    }
                    
                    // lotID
                    if let id = jsonDict["lot_id"] as? String {
                        lotID = UUID.init(uuidString: id)!
                    }
                    
                    // manufacturerUUID
                    if let id = jsonDict["manufacturer_uuid"] as? String {
                        manufacturerUUID = UUID.init(uuidString: id)!
                    }
    
                    if let major = jsonDict["major"] as? Int {
                        self.major = major
                    }
                    
                    if let minor = jsonDict["minor"] as? Int {
                        self.minor = minor
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
    
    static func create(lotID: UUID, manufacturerUUID: UUID, major: Int, minor: Int, coordinates: BeaconCoordinates, handler: @escaping (Beacon) -> Void) {
        
        // 1: create parameters payload
        let parameters: Parameters = ["lot_id" : lotID.uuidString,
                          "manufacturer_id" : manufacturerUUID.uuidString,
                          "coordinates" : ["x" : coordinates.x, "y" : coordinates.y],
                           "major": major,
                           "minor" : minor]
        
        let encasedParams: Parameters = ["beacon" : parameters]
        
        Alamofire.request("http://13.70.187.234/api/beacons", method: .post, parameters: encasedParams, encoding: JSONEncoding.default).responseString(completionHandler: { responseString in
            if let stringValue = responseString.value, let newBeacon = Beacon(jsonString: stringValue) {
                handler(newBeacon)
            }
        })
    }
}
