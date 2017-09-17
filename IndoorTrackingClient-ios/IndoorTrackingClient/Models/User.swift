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
    
    static func create(username: String, firstName: String, lastName: String, handler: (User) -> Void) {
        
        // 1: create on server
        
        // 2: with ok response, complete completion handler, pass in the new beacon object.
        
    }
    
    static func all(handler: @escaping ([User]) -> Void) {
        
        let requestURL = AppDelegate.apiRoot.appending("users/")
        
        Alamofire.request(requestURL).responseString { response in
            
            guard response.result.value != nil else {
                print("No response")
                return
            }
            
            var users = [User]()
            
            if let jsonData = response.result.value?.data(using: .utf8) {
                
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String:Any]] {
                        
                        for userDict in jsonArray {
                            if let user = User(dict: userDict) {
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












