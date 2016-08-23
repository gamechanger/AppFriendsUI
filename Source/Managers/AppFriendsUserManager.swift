//
//  AppFriendsUserManager.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/8/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import AppFriendsCore

public class AppFriendsUserManager: NSObject {

    public static let sharedInstance = AppFriendsUserManager()
    
    public func fetchUserFriends(userID: String, completion: ((response: AnyObject?, error: NSError?) -> ())? = nil) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.startRequest(httpMethod: "GET", path: "/users/\(userID)/friends", parameters: nil) { (response, error) in
            
            if let err = error {
                
                if let complete = completion {
                    complete(response: nil, error: err)
                }
            }
            else {
                
                // save user
                if let json = response as? [[String: AnyObject]]
                {
                    CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                        
                        var friends = [String]()
                        for userJson in json
                        {
                            HCUser.processUserInfo(userJson, transaction: transaction)
                            friends.append(userJson["id"] as! String)
                        }
                        
                        if let user = transaction.fetchOne(
                            From(HCUser),
                            Where("userID", isEqualTo: userID)
                            )
                        {
                            user.friends = friends
                        }
                        
                        transaction.commit({ (result) in
                            
                            if let complete = completion {
                                complete(response: response, error: nil)
                            }
                            
                        })
                    })
                }
                else {
                    
                    if let complete = completion {
                        complete(response: response, error: nil)
                    }
                }
            }
        }
    }
    
    public func updateUserInfo(userID: String, userInfo:[String: AnyObject], completion: ((response: AnyObject?, error: NSError?) -> ())? = nil)
    {
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.startRequest(httpMethod: "PUT", path: "/users/\(userID)", parameters: userInfo) { (response, error) in
            
            if let err = error {
                
                if let complete = completion {
                    complete(response: nil, error: err)
                }
            }
            else {
                
                // save user
                if let json = response
                {
                    CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                        HCUser.processUserInfo(json as! [String : AnyObject], transaction: transaction)
                        transaction.commit({ (result) in
                            
                            if let complete = completion {
                                complete(response: response, error: nil)
                            }
                            
                        })
                    })
                }
                else {
                    
                    if let complete = completion {
                        complete(response: response, error: nil)
                    }
                }
            }
        }
    }
    
    public func fetchUserInfo(userID: String, completion: ((response: AnyObject?, error: NSError?) -> ())? = nil)
    {
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.startRequest(httpMethod: "GET", path: "/users/\(userID)", parameters: nil) { (response, error) in
            
            if let err = error {
                
                if let complete = completion {
                    complete(response: nil, error: err)
                }
            }
            else {
                
                // save user
                if let json = response
                {
                    CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                        HCUser.processUserInfo(json as! [String : AnyObject], transaction: transaction)
                        transaction.commit({ (result) in
                            
                            if let complete = completion {
                                complete(response: response, error: nil)
                            }
                            
                        })
                    })
                }
                else {
                    
                    if let complete = completion {
                        complete(response: response, error: nil)
                    }
                }
            }
        }
    }

    
}
