//
//  HCDialogTableViewCell.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/11/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import SESlideTableViewCell

class HCDialogTableViewCell: SESlideTableViewCell {

    @IBOutlet weak var dialogAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: HCTopAlignedContentLabel!
    @IBOutlet weak var lastMessageTimeLabel: UILabel!
    
    var messageTime: NSDate?
    var addedRightButton = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = HCColorPalette.chatBackgroundColor
        self.contentView.backgroundColor = HCColorPalette.chatBackgroundColor
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        dialogAvatarImageView.layer.cornerRadius = 4
        dialogAvatarImageView.layer.masksToBounds = true
        dialogAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        dialogAvatarImageView.layer.borderWidth = 3
        dialogAvatarImageView.backgroundColor = HCColorPalette.avatarBackgroundColor
        dialogAvatarImageView.contentMode = .ScaleAspectFit
        
        NSTimer.runThisEvery(seconds: 30) { [weak self](timer) in
            self?.updateTime()
        }
    }
    
    override func addRightButtonWithText(text: String!, textColor: UIColor!, backgroundColor: UIColor!) {
        
        super.addRightButtonWithText(text, textColor: textColor, backgroundColor: backgroundColor)
        self.addedRightButton = true
    }
    
    override func addRightButtonWithImage(image: UIImage!, backgroundColor: UIColor!) {
        
        super.addRightButtonWithImage(image, backgroundColor: backgroundColor)
        self.addedRightButton = true
    }
    
    func updateTime()
    {
        if let messageTime = self.messageTime
        {
            self.lastMessageTimeLabel.text = messageTime.timeAgoSimple()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
