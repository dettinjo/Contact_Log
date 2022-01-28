//
//  DateTableViewCell.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 30.01.21.
//

import UIKit

class DateTableViewCell: UITableViewCell {
    
    static let identifier = "DateTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "DateTableViewCell", bundle: nil)
    }
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    
    func configure(with date: Date, address: String) {
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "E, d MMM yyyy"
        
        
        dateLabel.text = customFormatter.string(from: date)
        addressLabel.text = address
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
