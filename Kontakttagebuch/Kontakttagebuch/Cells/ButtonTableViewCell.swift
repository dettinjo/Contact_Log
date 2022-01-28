//
//  ButtonTableViewCell.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 28.01.21.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    static let identifier = "ButtonTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ButtonTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
