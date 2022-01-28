//
//  LocationTableViewCell.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 30.01.21.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    static let identifier = "LocationTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "LocationTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    
    
    func configure(with name: String, address: String) {
        locationLabel.text = name
        addressLabel.text = address
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
