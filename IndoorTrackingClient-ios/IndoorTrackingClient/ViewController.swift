//
//  ViewController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 9/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    let apiRoot = "http://13.70.187.234:3000/api/"

    override func viewDidLoad() {
        super.viewDidLoad()
        addRequestLabel()
    }
    
    // This function is called when the request label is tapped.
    func didTap(gesture: UITapGestureRecognizer) {
        
        getBeacon(withID: "02ea1174-0e7e-4245-a5f3-0ffe764905dc") { responseJSONString in
            self.presentAlert(message: responseJSONString)
        }
    }
    
    // Presents an alert with a dismiss button. Will show whatever is passed as the message.
    func presentAlert(message: String?) {
        let alert = UIAlertController(title: "Received response", message: message ?? "No response.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil) } )
        
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Gets information about a beacon for 'id', and performs 'handler' once a reponse is received.
    // 'handler' takes one argument, which is the body of the http response (in this case, is a json string).
    func getBeacon(withID id: String, handler: @escaping (String?) -> Void ) {
        
        let requestURL = apiRoot.appending("beacons/\(id)")
        
        Alamofire.request(requestURL).responseString { response in
            handler(response.result.value)
        }
    }
    
    // Adds the label to the view controller, centres it in the screen, and adds a tap handler to the label.
    private func addRequestLabel() {
        
        let label = UILabel()
        label.text = "TAP TO PERFORM REQUEST"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        
        let centreXConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centreYConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        // Setup tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        label.addGestureRecognizer(tapGesture)
        
        // Add the view to this view controller's main view
        self.view.addSubview(label)
        // Add the constraints, which move the label into the middle of the view.
        self.view.addConstraints([centreXConstraint, centreYConstraint])
    }
}





