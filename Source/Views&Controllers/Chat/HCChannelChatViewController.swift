//
//  HCChannelChatViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import EZSwiftExtensions

public class HCChannelChatViewController: HCBaseChatViewController{
    
    
    override public init(dialog: String) {
        
        super.init(dialog: dialog)
        
        _dialogType = HCSDKConstants.kMessageTypeChannel
        
        
    }
    
    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSTimer.runThisEvery(seconds: 140) { [weak self] (timer) in
            self?.renewChannelSession()
        }
    }
    
    deinit {
        
        NSLog("%@", "????")
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func renewChannelSession() {
        HCSDKCore.sharedInstance.renewSessionForPublicChannel(_dialogID)
    }
}
