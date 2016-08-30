//
//  HCUIConfiguration.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import EZSwiftExtensions

public class HCColorPalette {
    
    public static var chatBackgroundColor = UIColor(hexString: "0d0e28")
    public static var chatContentTextColor = UIColor.whiteColor()
    public static var chatUserNamelTextColor = UIColor.whiteColor()
    public static var chatTimeLabelTextColor = UIColor.lightGrayColor()
    public static var chatSystemMessageColor = UIColor.lightGrayColor()
    public static var chatSendButtonColor = UIColor(hexString: "0d0e28")
    public static var chatOutMessageBubbleColor = UIColor(hexString: "93d4f0")
    public static var chatInMessageBubbleColor = UIColor(hexString: "5e62bc")
    public static var chatMessageFailedButtonColor = UIColor(hexString: "f2433d")
    
    public static var avatarBackgroundColor = UIColor.init(white: 1, alpha: 0.3)
    
    public static var SegmentSelectorColor = UIColor.whiteColor()
    public static var SegmentSelectorOnBgColor = UIColor(hexString: "a5bac3")
    public static var SegmentSelectorOffBgColor = UIColor.clearColor()
    public static var SegmentSelectorOnTextColor = UIColor.whiteColor()
    public static var SegmentSelectorOffTextColor = UIColor.whiteColor()
    
    public static var contactsTableSeparatorColor = UIColor(hexString: "1F203D")
    
    public static var navigationBarIconColor = UIColor.whiteColor()
    public static var navigationBarTitleColor = UIColor.whiteColor()
    
    public static var badgeBackgroundColor = UIColor(hexString: "f2433d")
    
    public static var closeButtonBgColor = UIColor.whiteColor()
    public static var closeButtonIconColor = UIColor.blackColor()
    
    public static var searchBarBgColor = UIColor(hexString: "0d0e28")
}

public class HCSize {
    public static var ChatCellContentDefaultPointSize: CGFloat = 16.0
}

public class HCFont {
    public static var SegmentSelectorFont = UIFont.systemFontOfSize(15)
    public static var EmptyTableViewLabelFont = UIFont.systemFontOfSize(15)
    public static var ChatCellContentFontName = "Helvetica Neue"
}

public class HCTitles {
    
    public static var channelTabTitle = "Channels"
    public static var dialogsTabTitle = "Dialogs"
    public static var contactsTabTitle = "Friends"
}

public class HCConstants {
    public static var oldestMessageDays = 2
    public static var sidePanelSlideAnimationDuration = 0.25
    public static var sidePanelWindowWidth: CGFloat = 300.0
}
