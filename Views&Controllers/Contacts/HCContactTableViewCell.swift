//
//  HCContactTableViewCell.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/11/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

class HCContactTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = HCColorPalette.chatBackgroundColor
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        userAvatar.layer.cornerRadius = 4
        userAvatar.layer.masksToBounds = true
        userAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        userAvatar.layer.borderWidth = 3
        userAvatar.backgroundColor = HCColorPalette.avatarBackgroundColor
        userAvatar.contentMode = .ScaleAspectFit
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
