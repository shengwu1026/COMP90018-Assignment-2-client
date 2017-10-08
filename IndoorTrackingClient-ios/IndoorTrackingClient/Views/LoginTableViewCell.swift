//
//  LoginTableViewCell.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 5/10/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class LoginTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageLabel: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

class UserDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageLabel: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

protocol LotTableViewCellDelegate: NSObjectProtocol {
    func didTapConfig(cell: LotTableViewCell) -> Void
}

class LotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var configBeaconImageView: UIImageView!
    @IBOutlet weak var userImageLabel: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    weak var delegate: LotTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTapGestures()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupTapGestures() {
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTapConfig))
        self.configBeaconImageView.addGestureRecognizer(tapGestureRecogniser)
        self.configBeaconImageView.isUserInteractionEnabled = true
    }

    func didTapConfig() {
        self.delegate?.didTapConfig(cell: self)
    }
}

class BeaconInfoCell : UITableViewCell {
    
    @IBOutlet weak var userImageLabel: UIImageView!
    @IBOutlet weak var beaconLabel: UILabel!
    @IBOutlet weak var beaconDistanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}







