//
//  ConfirmRejectTableViewCell.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/5/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

class ConfirmRejectTableViewCell: UICollectionViewCell {

    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.rejectButton.layer.cornerRadius = 4
        self.rejectButton.layer.masksToBounds = true
        self.rejectButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.rejectButton.layer.borderWidth = 2
        
        self.acceptButton.layer.cornerRadius = 4
        self.acceptButton.layer.masksToBounds = true
        self.acceptButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.acceptButton.layer.borderWidth = 2
    }

}
