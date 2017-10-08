//
//  UserDetailController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 6/10/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class UserDetailController: UIViewController {
    
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var currentLocationLabelView: UILabel!
    
    @IBOutlet weak var locationView: LocationView!
    
    var user: User?

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
        
        guard user != nil else {
            return
        }
        
        user?.currentLotDimensions { (length, width) in
            self.locationView.dimensions = (length, width)
        }
        
        // user was set, so make sure we update the ui.
        if let firstName = user?.firstName,
           let lastName = user?.lastName {
            nameLabelView.text = "\(firstName) \(lastName)"
        }
    }
    
    func onTimerUpdate() {
        print("timer did fire")

        if let user = user {
            user.location { building, room, x, y in
                print("x: \(x), y: \(y)")
                // locationView takes locations in cm
                
                // Update the current room name.
                self.currentLocationLabelView.text = "\(building), \(room)"
                
                // Update the position in the room.
                self.locationView.setPositionForID(user.id.uuidString, position: CGPoint(x: x, y: y))
            }
        }
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
