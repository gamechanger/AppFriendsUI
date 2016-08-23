//
//  HCUIConfiguration.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class HCColorPalette {
    
    static var chatBackgroundColor = UIColor(hexString: "0d0e28")
    static var chatContentTextColor = UIColor.whiteColor()
    static var chatUserNamelTextColor = UIColor.whiteColor()
    static var chatTimeLabelTextColor = UIColor.lightGrayColor()
    static var chatSystemMessageColor = UIColor.lightGrayColor()
    static var chatSendButtonColor = UIColor(hexString: "0d0e28")
    static var chatOutMessageBubbleColor = UIColor(hexString: "93d4f0")
    static var chatInMessageBubbleColor = UIColor(hexString: "5e62bc")
    static var chatMessageFailedButtonColor = UIColor(hexString: "f2433d")
    
    static var avatarBackgroundColor = UIColor.init(white: 1, alpha: 0.3)
    
    static var SegmentSelectorColor = UIColor.whiteColor()
    static var SegmentSelectorOnBgColor = UIColor(hexString: "a5bac3")
    static var SegmentSelectorOffBgColor = UIColor.clearColor()
    static var SegmentSelectorOnTextColor = UIColor.whiteColor()
    static var SegmentSelectorOffTextColor = UIColor.whiteColor()
    
    static var contactsTableSeparatorColor = UIColor(hexString: "1F203D")
    
    static var navigationBarIconColor = UIColor.whiteColor()
    static var navigationBarTitleColor = UIColor.whiteColor()
    
    static var badgeBackgroundColor = UIColor(hexString: "f2433d")
}

class HCSize {
    static var ChatCellContentDefaultPointSize: CGFloat = 16.0
}

class HCFont {
    static var SegmentSelectorFont = UIFont.systemFontOfSize(15)
    static var EmptyTableViewLabelFont = UIFont.systemFontOfSize(15)
    static var ChatCellContentFontName = "Helvetica Neue"
}
