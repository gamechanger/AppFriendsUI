//
//  HCChatTableViewCell.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/10/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import SlackTextViewController
import EZSwiftExtensions
import NSDate_TimeAgo
import Google_Material_Design_Icons_Swift

public class HCChatTableViewCell: UITableViewCell {

    static let kChatCellTopMargin: CGFloat = 16.0
    static let kChatCellBottomMargin: CGFloat = 20.0
    static let kChatCellLeftMargin: CGFloat = 53.0
    static let kChatCellRightMargin: CGFloat = 39.0
    static let kChatCellMinimumHeight: CGFloat = 71.0
    static let kChatCellAvatarHeight: CGFloat = 25
    static let kImageCellHeight: CGFloat = 172.0
    
    @IBOutlet weak var userNameLabel: UILabel?
    @IBOutlet weak var messageContentLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var contentBackgroundBubble: UIImageView?
    @IBOutlet weak var contentImageView: UIImageView?
    @IBOutlet weak var failedButton: UIButton?
    
    var messageTime: NSDate?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.w/2
        userAvatarImageView.layer.masksToBounds = true
        userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userAvatarImageView.layer.borderWidth = 1
        userAvatarImageView.backgroundColor = HCColorPalette.avatarBackgroundColor
        userAvatarImageView.contentMode = .ScaleAspectFit
        
        userNameLabel?.textColor = HCColorPalette.chatUserNamelTextColor
        timeLabel.textColor = HCColorPalette.chatTimeLabelTextColor
        messageContentLabel?.numberOfLines = 0
        
        failedButton?.setGMDIcon(GMDType.GMDError, forState: .Normal)
        failedButton?.setTitleColor(HCColorPalette.chatMessageFailedButtonColor, forState: .Normal)
        
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        self.contentBackgroundBubble?.layer.cornerRadius = 5
        self.contentBackgroundBubble?.layer.masksToBounds = true
        
        self.contentImageView?.layer.cornerRadius = 5
        self.contentImageView?.layer.masksToBounds = true
        
        NSTimer.runThisEvery(seconds: 30) { [weak self](timer) in
            self?.updateTime()
        }
    }
    
    func updateTime()
    {
        if let messageTime = self.messageTime
        {
            self.timeLabel.text = messageTime.timeAgo()
        }
    }
    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func defaultPointSize() -> CGFloat {
        
        var pointSize = HCSize.ChatCellContentDefaultPointSize
        let contentSizeCategory = UIApplication.sharedApplication().preferredContentSizeCategory
        pointSize += SLKPointSizeDifferenceForCategory(contentSizeCategory)
        
        return pointSize
    }
    
    func setbubbleColor(color: UIColor) {
        
        self.contentBackgroundBubble?.backgroundColor = color
        self.contentImageView?.backgroundColor = color
        
//        self.contentBackgroundBubble.image = (self.contentBackgroundBubble.image?.imageWithRenderingMode(.AlwaysTemplate))!
//        self.contentBackgroundBubble.tintColor = color
    }
    
    @IBAction func resendButtonTapped(sender: AnyObject) {
        
        
        
    }
    
}
