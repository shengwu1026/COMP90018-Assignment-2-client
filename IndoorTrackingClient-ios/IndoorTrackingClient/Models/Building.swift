//
//  Building.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 29/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import Alamofire


struct Level {
    let int: Int
    let text: String
    let units: String
    let width: Double
    let height: Double
    let length: Double
}

struct Address {
    
    var city: String
    var state: String
    var suburb: String
    
    var streetName: String
    var unitNumber: String
    var streetNumber: String
    
    var postCode: Int
}

class Building {
    
    // Doing it this way with explicitly unwrapped optionals is bad
    // Don't do this. Only doing it for speed.
    // I'm assuming there will never be errors in the json
    // and everything will always be present.
    var id: UUID!
    var address: Address!
    var name: String!
    var levels: [Level]!
    
    init?(dict: [String:Any]) {
        
        // the building id
        if let id = dict["id"] as? String {
            self.id = UUID.init(uuidString: id)
        }
        
        // building_id
        if let address = dict["address"] as? [String : Any] {
            
            let city = address["city"] as? String ?? "Unknown"
            let state = address["state"] as? String ?? "Unknown"
            let suburb = address["suburb"] as? String ?? "Unknown"
            
            let streetName = address["street_name"] as? String ?? "Unknown"
            let unitNumber = address["unit_number"] as? String ?? "Unknown"
            let streetNumber = address["street_number"] as? String ?? "Unknown"
            
            let postCode = address["post_code"] as? Int ?? 0
            
            self.address = Address(city: city, state: state, suburb: suburb, streetName: streetName, unitNumber: unitNumber, streetNumber: streetNumber, postCode: postCode)
        }
        
        // building name
        if let name = dict["name"] as? String {
            self.name = name
        }
        
        // levels
        if let levels = dict["floor_levels"] as? [[String : Any]] {
            
            self.levels = []
            
            for level in levels {
                
                let integerForm = level["int"] as? Int ?? -1
                let text = level["text"] as? String ?? "Unknown"
                let units = level["units"] as? String ?? "Unknown"
                let width = level["width"] as? Double ?? -1
                let height = level["height"] as? Double ?? -1
                let length = level["length"] as? Double ?? -1
                
                let newLevel = Level(int: integerForm, text: text, units: units, width: width, height: height, length: length)
                self.levels.append(newLevel)
            }
        }
    }
    
    static func all(handler: @escaping ([Building]) -> Void) {
                
        // Get all the buildings.
        Alamofire.request("http://13.70.187.234/api/buildings").responseString { response in
            
            guard response.result.value != nil else {
                print("No response")
                return
            }
            
            var buildings = [Building]()
            
            if let jsonData = response.result.value?.data(using: .utf8) {
                
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] {
                        
                        // For each building
                        for userDict in jsonArray {
                            
                            if let building = Building(dict: userDict) {
                                buildings.append(building)
                            }
                        }
                    }
                }
                catch {
                    print(error)
                    return
                }
            }
            
            handler(buildings)
        }
    }
    
    static func create(address: Address, name: String, levels: [Level], handler: @escaping (Building) -> Void) {
        
        let floor: Parameters = ["int" : 0, "text" : "Ground Floor", "units" : "Metres", "width" : 100, "height" : 3, "length" : 100]
        
        let addressParams: Parameters = ["unit_number" : address.unitNumber,
                                         "street_number" : address.streetNumber,
                                         "street_name" : address.streetName,
                                         "suburb": address.suburb,
                                         "city" : address.city,
                                         "state" : address.state,
                                         "post_code" : address.postCode]
        
        let parameters: Parameters = ["name" : name,
                                      "address" : addressParams,
                                      "floor_levels" : [floor]]
        
        let encasedParams: Parameters = ["building" : parameters]
        
        print(parameters)
        
        Alamofire.request("http://13.70.187.234/api/buildings", method: .post, parameters: encasedParams, encoding: JSONEncoding.default).responseJSON(completionHandler: { responseJSON in
            if let dict = responseJSON.value as? [String : Any], let newBuilding = Building(dict: dict) {
                handler(newBuilding)
            }
        })
    }
}












