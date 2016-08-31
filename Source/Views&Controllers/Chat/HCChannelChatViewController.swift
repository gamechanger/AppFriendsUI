//
//  HCChannelChatViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore

public class HCChannelChatViewController: HCBaseChatViewController{
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func didPressRightButton(sender: AnyObject?) {
        
        if let text = self.textView.text
        {
            MessagingManager.sharedInstance.sendTextMessage(text, dialogID: _dialogID, dialogType: _dialogType)
        }
        
        super.didPressRightButton(sender)
    }

}
