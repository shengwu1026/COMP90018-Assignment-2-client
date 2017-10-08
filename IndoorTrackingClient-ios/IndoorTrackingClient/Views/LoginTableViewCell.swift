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

class LotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var configBeaconImageView: UIImageView!
    @IBOutlet weak var userImageLabel: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
