//
//  ActionButtonCell.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

class CancelActionButtonCell: UICollectionViewCell {

    static let identifier = "CancelActionButtonCell"
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cancelButton.layer.cornerRadius = 4
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.cancelButton.layer.borderWidth = 2
    }

}
