//
//  HCDialogTableViewCell.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/11/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import SESlideTableViewCell

public class HCDialogTableViewCell: SESlideTableViewCell {

    @IBOutlet weak var dialogAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: HCTopAlignedContentLabel!
    @IBOutlet weak var lastMessageTimeLabel: UILabel!
    
    var messageTime: NSDate?
    var addedRightButton = false
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = HCColorPalette.chatBackgroundColor
        self.contentView.backgroundColor = HCColorPalette.chatBackgroundColor
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        dialogAvatarImageView.backgroundColor = HCColorPalette.avatarBackgroundColor
        dialogAvatarImageView.contentMode = .ScaleAspectFit
        
        NSTimer.runThisEvery(seconds: 30) { [weak self](timer) in
            self?.updateTime()
        }
    }
    
    override public func addRightButtonWithText(text: String!, textColor: UIColor!, backgroundColor: UIColor!) {
        
        super.addRightButtonWithText(text, textColor: textColor, backgroundColor: backgroundColor)
        self.addedRightButton = true
    }
    
    override public func addRightButtonWithImage(image: UIImage!, backgroundColor: UIColor!) {
        
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

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
