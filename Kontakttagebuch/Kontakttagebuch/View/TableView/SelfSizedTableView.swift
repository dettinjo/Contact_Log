//
//  SelfSizedTableView.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 01.02.21.
//

import UIKit

class SelfSizedTableView: UITableView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    public var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: contentSize.width, height: contentSize.height)
    }
}
