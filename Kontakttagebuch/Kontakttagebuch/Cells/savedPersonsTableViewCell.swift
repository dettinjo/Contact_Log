//
//  savedPersonsTableViewCell.swift
//  Kontakttagebuch
//
//  Created by Nicole Zeh on 31.01.21.
//

import UIKit

class savedPersonsTableViewCell: UITableViewCell {
    
    static let identifier = "savedPersonsTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "savedPersonsTableViewCell", bundle: nil)
    }
    
    public func confiSavedPersons(personName: String, personNumber: String, count: Int ) {
        name.text = personName
        number.text = personNumber
        encounterCount.text = String(count)
    }
    
    @IBOutlet var name: UILabel!
    @IBOutlet var number: UILabel!
    @IBOutlet var encounterCount: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
