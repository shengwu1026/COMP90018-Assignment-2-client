//
//  LotDetailController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 7/10/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class LotDetailController: UIViewController {
    
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    
    @IBOutlet weak var locationView: LocationView!
    
    var lot: Lot?
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.onTimerUpdate()
        }
        
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // start timer to get location of user once per second
        // update the map.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // stop timer from updating the location of the user.
        timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload() {
        
        guard lot != nil else {
            return
        }
        
        // user was set, so make sure we update the ui.
        if let buildingName = lot?.building.name,
            let lotName = lot?.name {
            nameLabelView.text = "\(buildingName) \(lotName)"
        }
    }
    
    func onTimerUpdate() {
        
        if let lot = lot {
            lot.people { people in
             
                // Update the person count.
                let count = people.count
                let pluralOrNot = count == 1 ? "person" : "people"
                self.numberOfPeopleLabel.text = "\(count) \(pluralOrNot)"
                
                // Update the locations on the map.
                for person in people {
                    self.locationView.setPositionForID(person.0, position: person.1)
                }
            }
        }
        
        
        /*
        if let user = user {
            user.location { building, room, x, y in
                print("x: \(x), y: \(y)")
                // locationView takes locations in cm
                
                // Update the current room name.
                self.currentLocationLabelView.text = "\(building), \(room)"
                
                // Update the position in the room.
                self.locationView.setPositions(positions: [CGPoint(x: x * 100, y:y * 100)])
            }
        }
        */
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
