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
    
    public func followUser(userID: String, completion: ((response: AnyObject?, error: NSError?) -> ())? = nil) {
    
        let path = "/users/\(userID)/follow"
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.startRequest(httpMethod: "PUT", path: path, parameters: nil) { (response, error) in
            
            if let err = error {
                if let complete = completion {
                    complete(response: response, error: err)
                }
            }
            else {
                
                CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                    
                    if let currentUserID = HCSDKCore.sharedInstance.currentUserID()
                    {
                        let user = HCUser.findOrCreateUser(currentUserID, transaction: transaction)
                        if var followingUsers = user.following as? [String] where !followingUsers.contains(userID)
                        {
                            followingUsers.append(userID)
                            user.following = followingUsers
                        }
                        else {
                            let followingUsers = [userID]
                            user.following = followingUsers
                        }
                        
                        transaction.commit({ (result) in
                            
                            if let complete = completion {
                                complete(response: response, error: nil)
                            }
                        })
                    }
                })
            }
        }
    }
    
    public func unfollowUser(userID: String, completion: ((response: AnyObject?, error: NSError?) -> ())? = nil) {
        
        let path = "/users/\(userID)/unfollow"
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.startRequest(httpMethod: "PUT", path: path, parameters: nil) { (response, error) in
            
            if let err = error {
                if let complete = completion {
                    complete(response: response, error: err)
                }
            }
            else {
                CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                    
                    if let currentUserID = HCSDKCore.sharedInstance.currentUserID()
                    {
                        let user = HCUser.findOrCreateUser(currentUserID, transaction: transaction)
                        if var followingUsers = user.following as? [String]
                        {
                            followingUsers.removeObject(userID)
                            user.following = followingUsers
                        }
                        if var friends = user.friends as? [String]
                        {
                            friends.removeObject(userID)
                            user.friends = friends
                        }
                        
                        transaction.commit({ (result) in
                            
                            if let complete = completion {
                                complete(response: response, error: nil)
                            }
                        })
                    }
                })
            }
        }
    }
    
    public func fetchFollowers(userID: String, completion: ((response: AnyObject?, error: NSError?) -> ())? = nil) {
        
        let path = "/users/\(userID)/followers"
    }
    
    public func fetchFollowings(userID: String, completion: ((response: AnyObject?, error: NSError?) -> ())? = nil) {
        
        let path = "/users/\(userID)/followings"
    }
    
    public func searchUser(query: String, completion: ((response: AnyObject?, error: NSError?) -> ())? = nil) {

        if let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        {
            let appFriendsCore = HCSDKCore.sharedInstance
            let searchPath = "/users?search=\(escapedQuery)"
            appFriendsCore.startRequest(httpMethod: "GET", path: searchPath, parameters: nil) { (response, error) in
                
                
                if let err = error {
                    
                    if let complete = completion {
                        complete(response: nil, error: err)
                    }
                }
                else if let json = response as? [String: AnyObject]
                {
                    if let users = json["users"] as? [[String: AnyObject]]
                    {
                        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                            
                            for userJson in users
                            {
                                HCUser.processUserInfo(userJson, transaction: transaction)
                            }
                            transaction.commit({ (result) in
                                
                                if let complete = completion {
                                    complete(response: response, error: nil)
                                }
                            })
                        })
                    }
                }
            }
        }
        else {
            
            let error = NSError(domain: "AppFriendsError", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Invalid search query", NSLocalizedFailureReasonErrorKey: "Invalid search query"])
            
            if let complete = completion {
                complete(response: nil, error: error)
            }
        }
    }
    
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
