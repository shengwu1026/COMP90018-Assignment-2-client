//
//  LocationView.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 10/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import UIKit

// Basic components for rendering a single room (walls) 
// and the locations of people inside the room.

// All locations are specified in centre-origin space and then
// before they are drawn are converted to ios-top-left-origin space.

class LocationView : UIView {
    
    private let maxZoom: CGFloat = 10.0
    private let minZoom: CGFloat = 0.2
    
    private var scale: CGFloat = 0.4 {
        didSet {
            scale = max(minZoom, min(maxZoom, scale))
        }
    }
    
    // TODO: These are temporary positions, get rid of them and add them in the init.
    //private var positions: [CGPoint] = []
    private let colours: [UIColor] = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.brown, UIColor.black]
    
    private var positions = [String : CGPoint]()
    private var positionColours = [String : UIColor]()
    
    private let personIndicatorRadius: CGFloat = 20
    private let wallThickness: CGFloat = 15
    
    private var colorIndex = 0
    private var nextColor: UIColor {
        get {
            let color = colours[colorIndex]
            colorIndex = (colorIndex + 1) % colours.count
            return color
        }
    }
    
    // Public Functions
    // ################
    
    /*
    public func setPositions(positions: [CGPoint]) {
        self.positions = positions
        setNeedsDisplay()
    }
    */
    
    public func setPositionForID(_ id: String, position: CGPoint) {
        
        positions[id] = position
        
        // Choose a colour for this id.
        if positionColours[id] == nil {
            positionColours[id] = nextColor
        }
        
        setNeedsDisplay()
    }
    
    // Then also take in an array of current positions.
    // Redraw the entire map, but draw the positions of each client as circles which different colours.
    override init(frame: CGRect) {
        super.init(frame: frame)
        startup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startup()
    }
    
    private func startup() {
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        self.addGestureRecognizer(pinch)
    }
    
    @objc private func handlePinch(pinchGesture: UIPinchGestureRecognizer) {
        switch(pinchGesture.state) {
        case .changed:
            self.scale = self.scale * pinchGesture.scale
            pinchGesture.scale = 1
            self.setNeedsDisplay()
        default:
            break
        }
    }

    // Custom drawing of the view.
    
    override func draw(_ rect: CGRect) {
        // Render the walls.
        // TODO: These are temporary measurements. Make these customisable.
        
        UIColor.black.set()
        
        // Phill's room vertices.
        
        let length: Double = 7.1 * 100
        let width: Double = 4.93 * 100
        
        let alcoveLength = 1.85 * 100
        let alcoveWidth = 0.71 * 100
        
        let point1 = CGPoint(x: -(length/2), y: width/2)
        let point2 = CGPoint(x: length/2, y: width/2)
        let point3 = CGPoint(x: length/2, y: (width/2) - alcoveLength)
        let point4 = CGPoint(x: (length/2)-alcoveWidth, y: (width/2) - alcoveLength)
        let point5 = CGPoint(x: (length/2)-alcoveWidth, y: -(width/2))
        let point6 = CGPoint(x: -(length/2), y: -(width/2))

        let wallVertices = [point1, point2, point3, point4, point5, point6]
        
        /*
        let point1 = CGPoint(x: -100, y: 100)
        let point2 = CGPoint(x: 100, y: 100)
        let point3 = CGPoint(x: 100, y: -100)
        let wallVertices = [point1, point2, point3]
         */
        
        renderWalls(vertices: wallVertices)
        
        // Render the locations of any clients.
        renderPositions(positions)   
    }
    
    // Drawing Helpers
    // ###############
    
    private func drawCircleAtPoint(point: CGPoint, radius: CGFloat) {
        let path = UIBezierPath()
        path.addArc(withCenter: point, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        path.fill()
    }
    
    private func drawLine(from: CGPoint, to: CGPoint, thickness: CGFloat) {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        path.lineWidth = thickness
        
        path.lineCapStyle = .round
        path.stroke()
    }
    
    private func drawRectangle(_ rect: CGRect, thickness: CGFloat) {
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.origin.x  + rect.size.width, y: rect.origin.y)
        let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height)
        let bottomLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height)
        
        let path = UIBezierPath()
        path.move(to: topLeft)
        
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.addLine(to: topLeft)
        
        path.lineCapStyle = .round
        
        path.stroke()
    }
    
    // Rendering helpers
    private func renderWalls(vertices: [CGPoint]) {
        // Ensure we have at least 3 points.
        guard vertices.count >= 3 else {
            return
        }
        
        for pointIndex in 0..<vertices.count - 1  {
            
            var from = vertices[pointIndex]
            from.multiply(factor: scale)
            from.convertToViewSpace(withCenter: self.frame.center)
            
            var to = vertices[pointIndex + 1]
            to.multiply(factor: scale)
            to.convertToViewSpace(withCenter: self.frame.center)
            
            drawLine(from: from, to: to, thickness: wallThickness * scale)
        }
        
        var firstPoint = vertices[0]
        firstPoint.multiply(factor: scale)
        firstPoint.convertToViewSpace(withCenter: self.frame.center)
        
        var lastPoint = vertices[vertices.count - 1]
        lastPoint.multiply(factor: scale)
        lastPoint.convertToViewSpace(withCenter: self.frame.center)
        
        // Draw the final closing line.
        drawLine(from: lastPoint, to: firstPoint, thickness: wallThickness * scale)
    }
    
    // Future.
    private func renderLots() {
        
    }
    
    private func renderPositions(_ positions: [String : CGPoint]) {
        UIColor.red.set()
        
        // We pass positions in metres, we multiply by 100 to cm for the map view
        // Map view units are in cm.
        for (id, var position) in positions {
            positionColours[id]?.set()
            position.multiply(factor: 100) // to cm
            position.multiply(factor: scale) // take into account the zoom scale
            position.convertToViewSpace(withCenter: self.frame.center)
            drawCircleAtPoint(point: position, radius: personIndicatorRadius * scale)
        }
    }
}

extension CGPoint {
    mutating func multiply(factor: CGFloat) {
        self.x = self.x * factor
        self.y = self.y * factor
    }
    
    mutating func convertToViewSpace(withCenter center: CGPoint) {
        self.x = center.x + self.x
        self.y = (center.y + self.y * -1)
    }
}

extension CGRect {
    mutating func multiply(factor: CGFloat) {
        self.origin.x = self.origin.x * factor
        self.origin.y = self.origin.y * factor

        self.size.width = self.size.width * factor
        self.size.height = self.size.height * factor
    }
    
    mutating func convertToViewSpace(withCenter center: CGPoint) {
        self.origin.convertToViewSpace(withCenter: center)
    }
    
    var center: CGPoint {
        get {
            return CGPoint(x: self.width / 2, y: self.height / 2)
        }
    }
}












