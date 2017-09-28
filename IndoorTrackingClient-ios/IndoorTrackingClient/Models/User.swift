//
//  User.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 17/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

/*
{
    "id": "2c3e953d-9cfa-4d6e-986f-4df76ec7b3d6",
    "username": "seed.seed@seeds.com",
    "first_name": "Seed",
    "last_name": "Seed",
    "created_at": "2017-09-09T11:50:43.553+10:00",
    "updated_at": "2017-09-09T11:50:43.553+10:00"
}
*/

import Foundation
import Alamofire

class User {
    
    var id: UUID!
    var username: String!
    var firstName: String!
    var lastName: String!
    var createdAt: Date!
    var updatedAt: Date!
    
    var chip: Chip?
    
    init?(dict: [String:Any]) {
        
        // get the individual values
        
        // id
        if let id = dict["id"] as? String {
            self.id = UUID.init(uuidString: id)!
        }
        
        // username
        if let username = dict["username"] as? String {
            self.username = username
        }
        
        // firstName
        if let firstName = dict["first_name"] as? String {
            self.firstName = firstName
        }
        
        // lastName
        if let lastName = dict["last_name"] as? String {
            self.lastName = lastName
        }
        
        // createdAt
        if let createdAt = dict["created_at"] as? String {
            
            self.createdAt = Date()
            
            // TODO: figure out the proper date format for the date string being returned from the server.
            /*
             // 2017-09-09T10:23:04.301+10:00
             let formatter = DateFormatter()
             formatter.dateFormat = "yyyy-MM-dd’T’HH:mm:ss.SSSXXXXX"
             
             let lastActivityFromString = formatter.date(from: date)
             lastActivity = lastActivityFromString!
             */
        }
        
        // updatedAt
        if let updatedAt = dict["updated_at"] as? String {
            
            self.updatedAt = Date()
            
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
    
    // Create the beacon object from a JSON string.
    init?(jsonString: String) {
        
        if let jsonData = jsonString.data(using: .utf8) {
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
                
                // If we can convert the object to a dict
                if let jsonDict = jsonObject as? [String:Any] {
                    
                    // get the individual values
                    
                    // id
                    if let id = jsonDict["id"] as? String {
                        self.id = UUID.init(uuidString: id)!
                    }
                    
                    // username
                    if let username = jsonDict["username"] as? String {
                        self.username = username
                    }
                    
                    // firstName
                    if let firstName = jsonDict["first_name"] as? String {
                        self.firstName = firstName
                    }
                    
                    // lastName
                    if let lastName = jsonDict["last_name"] as? String {
                        self.lastName = lastName
                    }
                    
                    // createdAt
                    if let createdAt = jsonDict["created_at"] as? String {
                        
                        self.createdAt = Date()
                        
                        // TODO: figure out the proper date format for the date string being returned from the server.
                        /*
                         // 2017-09-09T10:23:04.301+10:00
                         let formatter = DateFormatter()
                         formatter.dateFormat = "yyyy-MM-dd’T’HH:mm:ss.SSSXXXXX"
                         
                         let lastActivityFromString = formatter.date(from: date)
                         lastActivity = lastActivityFromString!
                         */
                    }
                    
                    // updatedAt
                    if let updatedAt = jsonDict["updated_at"] as? String {
                        
                        self.updatedAt = Date()
                        
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
    
    func addNewChip(handler: @escaping (String) -> Void) {
        
        // Only want to add a new chip if one doesn't already exist for this user.
        guard self.chip == nil else {
            print("Chip was not nil, so exiting early.")
            return
        }
        
        let innerParams = ["user_id" : self.id.uuidString]
        let parameters = ["little_brother_chip" : innerParams]
        
        Alamofire.request("http://13.70.187.234/api/little_brother_chips", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { responseJSON in
            
            print(responseJSON)
            
            if let response = responseJSON.value as? [String : Any] {
                if let chipID = response["id"] as? String {
                    self.chip = Chip(id: chipID)
                    handler(chipID)
                }
            }
        }
    }
    
    // Super simple helper functions on the class.
    // ###########################################
    static func create(parameters: [String:Any], handler: @escaping (User) -> Void) {
        // 1: create on server
        // 2: with ok response, complete completion handler, pass in the new user object.
        
        let params = ["user" : parameters]
        
        Alamofire.request("http://13.70.187.234/api/users", method: .post, parameters: params, encoding: JSONEncoding.default).responseString(completionHandler: { responseString in
            if let stringValue = responseString.value, let newUser = User(jsonString: stringValue) {
                handler(newUser)
            }
        })
    }
    
    static func create(username: String, firstName: String, lastName: String, password: String, handler: @escaping (User) -> Void) {
        // 1: create on server
        // 2: with ok response, complete completion handler, pass in the new user object.
        
        let parameters = ["first_name" : firstName,
                          "last_name" : lastName,
                          "username": username,
                          "password" : password]
        
        Alamofire.request("http://13.70.187.234/api/users", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseString(completionHandler: { responseString in
            if let stringValue = responseString.value,
                let newUser = User(jsonString: stringValue) {
                handler(newUser)
            }
        })
    }
    
    static func all(handler: @escaping ([User]) -> Void) {
        
        let requestURL = AppDelegate.apiRoot.appending("users/")
        
        // Get a list of all the chips first.
        // Need to get the chip for each user.
        
        // See if there are any chips that have this user associated, if so, set the chip id for this user.
        Alamofire.request("http://13.70.187.234/api/little_brother_chips").responseJSON { response in
            
            if let arrayOfChips = response.value as? [[String : String]] {
                
                // Get all the users.
                Alamofire.request(requestURL).responseString { response in
                    
                    guard response.result.value != nil else {
                        print("No response")
                        return
                    }
                    
                    var users = [User]()
                    
                    if let jsonData = response.result.value?.data(using: .utf8) {
                        
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] {
                                
                                // For each user, check if there is an associated chip.
                                for userDict in jsonArray {
                                    if let user = User(dict: userDict) {
                                        
                                        if let associatedChip = arrayOfChips.filter({ $0["user_id"]?.lowercased() == user.id.uuidString.lowercased()}).first {
                                            user.chip = Chip(id: associatedChip["id"]!)
                                        }
                                        
                                        users.append(user)
                                    }
                                }
                            }
                        }
                        catch {
                            print(error)
                            return
                        }
                    }
                    
                    handler(users)
                }
            }
        }
    }
}












