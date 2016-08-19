//
//  HCUIConfiguration.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import EZSwiftExtensions

struct HCColorPalette {
    
    static let chatBackgroundColor = UIColor(hexString: "0d0e28")
    static let chatContentTextColor = UIColor.whiteColor()
    static let chatUserNamelTextColor = UIColor.whiteColor()
    static let chatTimeLabelTextColor = UIColor.lightGrayColor()
    static let chatSystemMessageColor = UIColor.lightGrayColor()
    static let chatSendButtonColor = UIColor(hexString: "0d0e28")
    static let chatOutMessageBubbleColor = UIColor(hexString: "93d4f0")
    static let chatInMessageBubbleColor = UIColor(hexString: "5e62bc")
    static let chatMessageFailedButtonColor = UIColor(hexString: "f2433d")
    
    static let avatarBackgroundColor = UIColor.init(white: 1, alpha: 0.3)
    
    static let SegmentSelectorColor = UIColor.whiteColor()
    static let SegmentSelectorOnBgColor = UIColor(hexString: "a5bac3")
    static let SegmentSelectorOffBgColor = UIColor.clearColor()
    static let SegmentSelectorOnTextColor = UIColor.whiteColor()
    static let SegmentSelectorOffTextColor = UIColor.whiteColor()
    
    static let contactsTableSeparatorColor = UIColor(hexString: "1F203D")
    
    static let navigationBarIconColor = UIColor.whiteColor()
}

struct HCSize {
    static let ChatCellContentDefaultPointSize: CGFloat = 16.0
}

struct HCFont {
    static let SegmentSelectorFont = UIFont.systemFontOfSize(15)
    static let EmptyTableViewLabelFont = UIFont.systemFontOfSize(15)
    static let ChatCellContentFontName = "Helvetica Neue"
}
