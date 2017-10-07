//
//  UserChipController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 28/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class UserChipController: UIViewController {

    @IBOutlet weak var chipImage: UIImageView!
    @IBOutlet weak var attachChipImageVIew: UIImageView!
    
    var user: User?
    
    var chipIDLabel = UILabel()
    var detailInfoLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = user?.firstName ?? "User"
        setupButton()
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload() {
        setupLabel()
        reloadUI()
    }
    
    private func setupButton() {
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTapAddChip))
        self.attachChipImageVIew.addGestureRecognizer(tapGestureRecogniser)
        self.attachChipImageVIew.isUserInteractionEnabled = true
    }
    
    private func reloadUI() {
        
        if user?.chip == nil {
            // We should show the attach chip button.
            attachChipImageVIew.isHidden = false
        }
        else {
            // We attached a chip, so show its details.
            attachChipImageVIew.isHidden = true
            setupLabel()
        }
    }
    
    private func setupLabel() {
        
        chipIDLabel.removeFromSuperview()
        chipIDLabel.translatesAutoresizingMaskIntoConstraints = false
        chipIDLabel.font = UIFont.boldSystemFont(ofSize: 12)
        chipIDLabel.textColor = UIColor.white
        
        if let uuid = user?.chip?.id {
            chipIDLabel.text = "\(uuid)"
        }
        
        chipIDLabel.sizeToFit()
        
        var constraints = constraintToChainBottomView(chipIDLabel, toTopView: chipImage)
        constraints += equalityConstraintForView(chipIDLabel, andAttribute: .centerX, withView: chipImage)
        
        self.view.addSubview(chipIDLabel)
        self.view.addConstraints(constraints)
    }
    
    private func updateLabelText(text: String) {
        self.chipIDLabel.text = text
        self.chipIDLabel.sizeToFit()
    }
    
    func didTapAddChip() {
        user?.addNewChip { chipID in
            self.reload()
        }
    }
}
