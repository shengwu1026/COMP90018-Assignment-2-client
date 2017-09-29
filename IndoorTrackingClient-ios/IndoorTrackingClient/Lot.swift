//
//  Lot.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 29/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import Alamofire

struct LotDimensions {
    var units: String
    var width: Double
    var height: Double
    var length: Double
}

class Lot {
    
    // Doing it this way with explicitly unwrapped optionals is bad
    // Don't do this. Only doing it for speed.
    // I'm assuming there will never be errors in the json
    // and everything will always be present.
    var id: UUID!
    var buildingId: UUID!
    var lotType: String!
    var name: String!
    var floorLevel: Int!
    
    var dimensions: LotDimensions!
    
    var building: Building!
    
    init?(dict: [String:Any]) {
        
        // the lot id
        if let id = dict["id"] as? String {
            self.id = UUID.init(uuidString: id)
        }
        
        // building_id
        if let buildingId = dict["building_id"] as? String {
            self.buildingId = UUID.init(uuidString: buildingId)!
        }
        
        // lot_type
        if let lotType = dict["lot_type"] as? String {
            self.lotType = lotType
        }
        
        // name
        if let name = dict["name"] as? String {
            self.name = name
        }
        
        // floor_level
        if let floorLevel = dict["floor_level"] as? Int {
            self.floorLevel = floorLevel
        }
        
        // dimensions
        if let dimensions = dict["dimensions"] as? [String : Any] {

            let units = dimensions["units"] as? String ?? "Metres"
            let width = dimensions["width"] as? Double ?? 0
            let height = dimensions["height"] as? Double ?? 0
            let length = dimensions["length"] as? Double ?? 0
            
            self.dimensions = LotDimensions(units: units, width: width, height: height, length: length)
        }
    }
    
    static func all(handler: @escaping ([Lot]) -> Void) {
        
        // Get all the buildings, as we want to attach the building that this lot belongs to.
        Alamofire.request("http://13.70.187.234/api/buildings").responseJSON { response in
            
            if let arrayOfBuildings = response.value as? [[String : Any]] {
                
                // Get all the lots.
                Alamofire.request("http://13.70.187.234/api/lots").responseString { response in
                    
                    guard response.result.value != nil else {
                        print("No response")
                        return
                    }
                    
                    var lots = [Lot]()
                    
                    if let jsonData = response.result.value?.data(using: .utf8) {
                        
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] {
                                
                                // For each lot, check if there is an associated building.
                                for userDict in jsonArray {
                                    if let lot = Lot(dict: userDict) {
                                        
                                        if let associatedBuilding = arrayOfBuildings.filter({ ($0["id"] as! String).lowercased() == lot.buildingId.uuidString.lowercased()}).first {
                                            if let building = Building(dict: associatedBuilding) {
                                                lot.building = building
                                            }
                                        }
                                        
                                        lots.append(lot)
                                    }
                                }
                            }
                        }
                        catch {
                            print(error)
                            return
                        }
                    }
                    
                    handler(lots)
                }
            }
        }
    }
    
    // Really need an API call where I can get the lots for a given building ID
    static func lotsForBuildingWithID(buildingID: UUID, handler: @escaping ([Lot]) -> Void) {
        Lot.all { lots in
            // Only want to return the lots that have this building id.
            var lotsInBuilding = [Lot]()
            
            for lot in lots {
                if lot.buildingId == buildingID {
                    lotsInBuilding.append(lot)
                }
            }
            
            handler(lotsInBuilding)
        }
    }
    
    static func create(buildingID: UUID, lotType: String, name: String, floorLevel: Int, dimensions: LotDimensions, rssi1m: Int, phoneHeight: Double, pathLoss: Double, handler: @escaping (Lot) -> Void) {
        
        let dimensionParams: Parameters = ["units" : dimensions.units,
                                         "width" : dimensions.width,
                                         "height" : dimensions.height,
                                         "length": dimensions.length]
        
        let parameters: Parameters = ["building_id" : buildingID.uuidString,
                                      "lot_type" : lotType,
                                      "name" : name,
                                      "floor_level" : floorLevel,
                                      "dimensions" : dimensionParams,
                                      "rssi_1m_away_from_beacon" : rssi1m,
                                      "average_phone_height" : phoneHeight,
                                      "path_loss" : pathLoss]
        
        let encasedParams: Parameters = ["lot" : parameters]
        
        Alamofire.request("http://13.70.187.234/api/lots", method: .post, parameters: encasedParams, encoding: JSONEncoding.default).responseJSON(completionHandler: { responseJSON in
            if let dict = responseJSON.value as? [String : Any], let newLot = Lot(dict: dict) {
                handler(newLot)
            }
        })
    }
}
