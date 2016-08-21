//
//  DialogsManager.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/17/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import EZSwiftExtensions
import AppFriendsCore

class DialogsManager: NSObject {
    
    
    static let sharedInstance = DialogsManager()
    
    // MARK: Dialogs
    
    func updateDialogName(dialogID: String, dialogName: String, completion: ((error: NSError?) -> ())? = nil)
    {
        HCSDKCore.sharedInstance.startRequest(httpMethod: "PUT", path: "/dialogs/\(dialogID)", parameters: ["name": dialogName])
        { (response, error) in
            
            
            if let err = error {
                completion?(error: err)
            }
            else
            {
                CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                    
                    if let dialog = transaction.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo: dialogID))
                    {
                        dialog.title = dialogName
                        transaction.commit({ (result) in
                            completion?(error: nil)
                        })
                    }
                })
            }
        }
    }
    
    func fetchDialogInfo(dialogID: String, completion: ((error: NSError?) -> ())? = nil)
    {
        HCSDKCore.sharedInstance.startRequest(httpMethod: "GET", path: "/dialogs/\(dialogID)", parameters: nil) { (response, error) in
            
            if let err = error {
                completion? (error: err)
            }
            else if let dialogInfo = response as? [String: AnyObject]  {
                
                CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                    
                    if let dialogID = dialogInfo["id"] as? String, let name = dialogInfo["name"] as? String, let members = dialogInfo["members"] as? [String], let type = dialogInfo["type"] as? String
                    {
                        HCChatDialog.findOrCreateDialog(dialogID, members: members, dialogTitle: name, dialogType: type, transaction: transaction)
                    }
                    
                    transaction.commit({ (result) in
                        
                        if let complete = completion {
                            complete(error: nil)
                        }
                        
                    })
                })
                
            }else {
                completion?(error:nil)
            }
        }
    }
    
    
    func addMembersToDialog(dialogID: String, members newMembers:[String], completion: ((error: NSError?) -> ())? = nil)
    {
        if newMembers.count > 0 {
            HCSDKCore.sharedInstance.startRequest(httpMethod: "POST", path: "/dialogs/\(dialogID)/members", parameters: ["members": newMembers], completion: { (response, error) in
                
                if let err = error {
                    completion?(error:err)
                }
                else {
                    
                    CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                        
                        for userID in newMembers
                        {
                            let dialog = HCChatDialog.findDialog(dialogID, transaction: transaction)
                            let user = HCUser.findOrCreateUser(userID, transaction: transaction)
                            dialog?.addMembersObject(user)
                        }
                        
                        transaction.commit({ (result) in
                            
                            if result.boolValue {
                                completion?(error: nil)
                            }
                            else {
                                let coreDataError = NSError(domain: "AppFriendsError", code: 1000, userInfo: [NSLocalizedDescriptionKey: result.debugDescription, NSLocalizedFailureReasonErrorKey: result.debugDescription])
                                completion?(error: coreDataError)
                            }
                        })
                    })
                }
                
            })
        }
    }
    
    func leaveGroupDialog(dialogID: String, completion: ((error: NSError?) -> ())? = nil)
    {
        
        if let currentUserID = HCSDKCore.sharedInstance.currentUserID()
        {
            let path = "/dialogs/\(dialogID)/members"
            let params = ["members":[currentUserID]]
            HCSDKCore.sharedInstance.startRequest(httpMethod: "DELETE", path: path, parameters: params, completion: { (response, error) in
                
                if let err = error {
                    
                    completion? (error: err)
                }
                else {
                    CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                        
                        if let dialog = HCChatDialog.findDialog(dialogID, transaction: transaction)
                        {
                            transaction.delete(dialog)
                        }
                        transaction.commit({ (result) in
                            completion?(error: error)
                        })
                    })
                }
            })
        }
    }
    
    /**
     Getting the list of dialogs
     
     - parameter completion: complete block, invoked when the request is completed
     */
    func fetchDialogs(completion: ((error: NSError?) -> ())? = nil)
    {
        HCSDKCore.sharedInstance.startRequest(httpMethod: "GET", path: "/dialogs", parameters: nil) { (response, error) in
            
            if let err = error {
                
                if let complete = completion {
                    complete(error: err)
                }
            }
            else if let json = response as? [[String: AnyObject]]  {
                
                CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                    
                    for dialogInfo in json
                    {
                        if let dialogID = dialogInfo["id"] as? String, let name = dialogInfo["name"] as? String, let members = dialogInfo["members"] as? [String], let type = dialogInfo["type"] as? String
                        {
                            HCChatDialog.findOrCreateDialog(dialogID, members: members, dialogTitle: name, dialogType: type, transaction: transaction)
                        }
                    }
                    
                    transaction.commit({ (result) in
                        
                        if let complete = completion {
                            complete(error: nil)
                        }
                        
                    })
                })
                
            }else {
                completion?(error:nil)
            }
        }
    }
    
    func createGroupDialog(users: [String], completion: ((response: AnyObject?, error: NSError?) -> ())? = nil) {
        
        var params = [String: AnyObject]()
        var userIDs = [String]()
        userIDs.appendContentsOf(users)
        if let userID = HCSDKCore.sharedInstance.currentUserID()
        {
            if !users.contains(userID) {
                userIDs.append(userID)
            }
        }
        params["members"] = userIDs
        
        HCSDKCore.sharedInstance.startRequest(httpMethod: "POST", path: "/dialogs", parameters: params) { (response, error) in
            
            if let err = error {
                
                if let complete = completion {
                    complete(response: nil, error: err)
                }
            }
            else if let json = response {
                
                let dialogID = json["id"] as! String
                HCChatDialog.createDialog(dialogID, members: userIDs, groupTitle: "", dialogType: HCSDKConstants.kDialogTypeGroup, completion: { (error) in
                    
                    if let complete = completion {
                        complete(response: response, error: nil)
                    }
                })
            }
        }
        
    }
    
}
