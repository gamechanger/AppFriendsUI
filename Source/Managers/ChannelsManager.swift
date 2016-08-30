//
//  ChannelsManager.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import EZSwiftExtensions
import AppFriendsCore

public class ChannelsManager: NSObject {

    public static let sharedInstance = ChannelsManager()
    
    public func fetchChannelInfo(channelID: String, completion: ((error: NSError?) -> ())? = nil)
    {
        HCSDKCore.sharedInstance.startRequest(httpMethod: "GET", path: "/channels/\(channelID)", parameters: nil)
        { (response, error) in
            
            
            if let err = error {
                completion?(error: err)
            }
            else  if let channelInfo = response as? [String: AnyObject]
            {
                
                
                CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                    
                    transaction.commit({ (result) in
                        completion?(error: nil)
                    })
                })
            }
        }
    }
    
}
