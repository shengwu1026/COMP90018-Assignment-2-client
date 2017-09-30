//
//  MapViewController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 10/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import UIKit

class MapViewController : UIViewController {
    
    let map: LocationView = LocationView()
    
    var displayLink: CADisplayLink?
    var previousTimestamp: Double = 0
    var currentTimestamp: Double = 0
    var t: Double = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        setupMapConstraints()
        
        // deal with positions
        /*
        displayLink = CADisplayLink(target: self, selector: #selector(animationUpdate))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        displayLink?.isPaused = false
        */
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.timerDidFire(timer: timer)
        }
    }
    
    @objc private func animationUpdate() {
        t = t + timeSinceLastFrame()
        
        let p1 = getPosition(centre: CGPoint(x: -2, y: -2), radius: 3, t: t)
        let p2 = getPosition(centre: CGPoint(x: 2, y: 2), radius: 3, t: t + Double.pi)
        let positions = [p1, p2]
        
        map.setPositions(positions: positions)
    }
    
    private func timeSinceLastFrame() -> Double {
        
        guard displayLink != nil else {
            return 0
        }
        
        if previousTimestamp == 0 {
            previousTimestamp = displayLink!.timestamp
        } else {
            previousTimestamp = currentTimestamp
        }
        
        currentTimestamp = displayLink!.timestamp
        
        var dt = currentTimestamp - previousTimestamp
        
        if dt > 0.032 {
            dt = 0.032
        }
        
        return dt
    }
    
    private func setupMapConstraints() {
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: map, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: map, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: map, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: map, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
        
        let constraints = [leftConstraint, topConstraint, heightConstraint, widthConstraint]
        
        self.view.addSubview(map)
        self.view.addConstraints(constraints)
    }
    
    // Testing
    // t is some value 0..2*pi
    private func getPosition(centre: CGPoint, radius: Double, t: Double) -> CGPoint {
        
        let x = centre.x + CGFloat(radius * cos(t))
        let y = centre.y + CGFloat(radius * sin(t))
        
        return CGPoint(x: x, y: y)
    }
    
    func timerDidFire(timer: Timer) -> Void {
        let user =  UserSettings.shared.currentUser
        
        user?.location { (x, y) in
            self.map.setPositions(positions: [CGPoint(x: x, y: y)])
        }
    }
}




