//
//  UserChipController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 28/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class UserChipController: UIViewController {

    var user: User? {
        didSet {
            reload()
        }
    }
    
    var chipIDLabel = UILabel()
    var detailInfoLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Chip Details"
        self.view.backgroundColor = UIColor.white
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func reload() {
        setupBarButtonItems()
        setupLabel()
    }

    private func setupBarButtonItems() {
        // Check if the user has an associated chip.
        if(user?.chip == nil) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Chip", style: .plain, target: self, action: #selector(didTapAddChip))
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func setupLabel() {
        
        chipIDLabel.removeFromSuperview()
        detailInfoLabel.removeFromSuperview()
        
        chipIDLabel.translatesAutoresizingMaskIntoConstraints = false
        chipIDLabel.sizeToFit()
        
        if let firstName = user?.firstName, let _ = user?.chip?.id {
            detailInfoLabel.text = "Chip UUID for \(firstName):"
        }
        
        detailInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        chipIDLabel.sizeToFit()
        
        let constraints = constraintsToCentreView(chipIDLabel, inContainingView: self.view)
        self.view.addSubview(chipIDLabel)
        self.view.addConstraints(constraints)
        

        var topLabelConstraints = constraintToChainBottomView(chipIDLabel, toTopView: detailInfoLabel, withConstant: 10)
        topLabelConstraints.append(NSLayoutConstraint(item: detailInfoLabel, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addSubview(detailInfoLabel)
        self.view.addConstraints(topLabelConstraints)
        
        if let chipID = user?.chip?.id {
            updateLabelText(text: chipID)
        }
    }
    
    private func updateLabelText(text: String) {
        self.chipIDLabel.text = text
        self.chipIDLabel.sizeToFit()
    }
    
    func didTapAddChip() {
        print("did tap add chip")
        user?.addNewChip { chipID in
            self.reload()
        }
    }
}
