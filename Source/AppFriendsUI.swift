//
//  AppFriendsUI.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/29/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

public class AppFriendsUI: NSObject {
    
    public static let sharedInstance = AppFriendsUI()
    
    public func initialize(completion: ((success: Bool, error: NSError?) -> ())? = nil)
    {
        CoreStoreManager.sharedInstance.initialize { (success, error) in
        
            if success {
                MessagingManager.startReceivingMessage()
                completion?(success: success, error: nil)
            }
            else {
                completion?(success: success, error: error)
            }
        }
    }
}
