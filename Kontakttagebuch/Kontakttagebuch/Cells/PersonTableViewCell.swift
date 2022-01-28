//
//  PersonTableViewCell.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 28.01.21.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    static let identifier = "PersonTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "PersonTableViewCell", bundle: nil)
    }
    
    
    @IBOutlet weak var personName: UILabel!
    
    func configure(with title: String) {
        personName.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
