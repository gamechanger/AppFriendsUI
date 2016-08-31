//
//  MessagingManager.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import EZSwiftExtensions
import AppFriendsCore

public class MessagingManager: NSObject, HCSDKCoreSyncDelegate {
    
    let messageCreateSem = dispatch_semaphore_create(1) // lock to serialize message creation
    
    public static let sharedInstance = MessagingManager()
    
    public static func startReceivingMessage()
    {
        HCSDKCore.sharedInstance.syncDelegate = sharedInstance
    }
    
    override init()
    {
        super.init()
    }
    
    // MARK: HCSDKCoreSyncDelegate
    
    public func messagesReceived(messages: [[String : AnyObject]]) {
        
        for messageJSON in messages
        {
            self.processMessageJSONFromServer(messageJSON)
        }
    }
    
    // MARK: Sending Image Message
    
    public func sendImageMessage(imageURL: String, dialogID: String, dialogType: String)
    {
        let messageJSON = createImageMessageJSON(imageURL, dialogID: dialogID)
        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
            HCMessage.createMessage(messageJSON, transaction: transaction)
            HCChatDialog.updateDialogLastMessage(dialogID, transaction: transaction)
            transaction.commit()
        })
        
        if dialogType == HCSDKConstants.kMessageTypeGroup
        {
            HCSDKCore.sharedInstance.sendMessage(messageJSON, dialogID: dialogID) { (response, error) in
                
                if let _ = error
                {
                    // report error?
                    if let tempID = messageJSON["temp_id"] as? String
                    {
                        self.failMessage(tempID)
                    }
                }
                else {
                    self.processMessageJSONFromServer(response as? [String: AnyObject])
                }
            }
        }
        else if dialogType == HCSDKConstants.kMessageTypeIndividual
        {
            HCSDKCore.sharedInstance.sendMessage(messageJSON, userID: dialogID) { (response, error) in
                
                if let _ = error
                {
                    // report error?
                    if let tempID = messageJSON["temp_id"] as? String
                    {
                        self.failMessage(tempID)
                    }
                }
                else {
                    self.processMessageJSONFromServer(response as? [String: AnyObject])
                }
            }
        }
    }
    
    // MARK: Sending Text Message
    
    public func sendTextMessage(text: String, dialogID: String, dialogType: String) {
        
        let messageJSON = createTextMessageJSON(text, dialogID: dialogID)
        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
            HCMessage.createMessage(messageJSON, transaction: transaction)
            HCChatDialog.updateDialogLastMessage(dialogID, transaction: transaction)
            transaction.commit()
        })
        
        
        if dialogType == HCSDKConstants.kMessageTypeGroup
        {
            HCSDKCore.sharedInstance.sendMessage(messageJSON, dialogID: dialogID) { (response, error) in
                
                if let _ = error
                {
                    // report error?
                    if let tempID = messageJSON["temp_id"] as? String
                    {
                        self.failMessage(tempID)
                    }
                }
                else {
                    self.processMessageJSONFromServer(response as? [String: AnyObject])
                }
            }
        }
        else if dialogType == HCSDKConstants.kMessageTypeIndividual
        {
            HCSDKCore.sharedInstance.sendMessage(messageJSON, userID: dialogID) { (response, error) in
                
                if let _ = error
                {
                    // report error?
                    if let tempID = messageJSON["temp_id"] as? String
                    {
                        self.failMessage(tempID)
                    }
                }
                else {
                    self.processMessageJSONFromServer(response as? [String: AnyObject])
                }
            }
        }
        else if dialogType == HCSDKConstants.kMessageTypeChannel
        {
            HCSDKCore.sharedInstance.sendMessage(messageJSON, channelID: dialogID) { (response, error) in
                
                if let _ = error
                {
                    // report error?
                    if let tempID = messageJSON["temp_id"] as? String
                    {
                        self.failMessage(tempID)
                    }
                }
                else {
                    self.processMessageJSONFromServer(response as? [String: AnyObject])
                }
            }
        }
    }
    
    // MARK: Create message JSON
    
    func basicMessageJSON(text: String, dialogID: String) -> NSMutableDictionary
    {
        let messageJSON = NSMutableDictionary()
        messageJSON["temp_id"] = HCUtils.createUniqueID() // create a global unique id here for your message
        messageJSON["sent_time"] = NSInteger(NSDate().timeIntervalSince1970 * 1000) // ms
        messageJSON["receive_time"] = NSInteger(NSDate().timeIntervalSince1970 * 1000) // m
        messageJSON["dialog_id"] = dialogID
        messageJSON["text"] = text
        
        return messageJSON
    }
    
    public func createTextMessageJSON(text: String, dialogID: String) -> NSDictionary
    {
        let messageJSON = basicMessageJSON(text, dialogID:  dialogID)
        let senderJSON = createSenderJSON()
        messageJSON["custom_data"] = ["sender": senderJSON].toString()
        return messageJSON
    }
    
    public func createImageMessageJSON(url: String, dialogID: String) -> NSDictionary
    {
        let messageJSON = basicMessageJSON("[image]", dialogID:  dialogID)
        let senderJSON = createSenderJSON()
        let attachmentJSON = createImagePayloadJSON(url)
        let customData = NSMutableDictionary()
        customData["sender"] = senderJSON
        customData["attachment"] = attachmentJSON
        messageJSON["custom_data"] = customData.toString()
        return messageJSON
    }
    
    public func createSenderJSON() -> NSDictionary {
        
        let messageJSON = NSMutableDictionary()
        messageJSON["id"] = HCSDKCore.sharedInstance.currentUserID()
        messageJSON["user_name"] = HCSDKCore.sharedInstance.currentUserName()
        
        if let userID = HCSDKCore.sharedInstance.currentUserID(), let currentUser = CoreStoreManager.store()?.fetchOne(
            From(HCUser),
            Where("userID", isEqualTo: userID)
            )
        {
            messageJSON["avatar"] = currentUser.avatar
        }else {
            messageJSON["avatar"] = ""
        }
        
        return messageJSON
    }
    
    public func createImagePayloadJSON(imageURL: String) -> NSDictionary {
        
        let attachmentJSON = NSMutableDictionary()
        attachmentJSON["type"] = "image"
        attachmentJSON["payload"] = ["url": imageURL]
        
        return attachmentJSON
    }
    
    // MARK: process message response
    
    public func failMessage(tempID: String)
    {
        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
            if let message = HCMessage.findMessage(tempID, transaction: transaction)
            {
                message.failed = true
                transaction.commit()
            }
        })
    }
    
    func processChatMessageJSON(messageJSON: [String: AnyObject]) {
        
        if let tempID = messageJSON["temp_id"] as? String
        {
            CoreStoreManager.store()!.beginAsynchronous({ (transaction) in
                
                dispatch_semaphore_wait(self.messageCreateSem, DISPATCH_TIME_FOREVER)
                
                let isNewMessage = HCMessage.findMessage(tempID, transaction: transaction) == nil
                let message = HCMessage.findOrCreateMessage(tempID: tempID, transaction: transaction)
                HCMessage.updateMessage(messageJSON, message: message, transaction: transaction)
                message.failed = false
                
                // if this is a new message, update dialog unread message info
                let currentUserID = HCSDKCore.sharedInstance.currentUserID()
                if isNewMessage, let dialogID = messageJSON["dialog_id"] as? String
                {
                    if message.senderID != currentUserID
                    {
                        if let dialog = HCChatDialog.findDialog(dialogID, transaction: transaction)
                        {
                            if message.receiveTime > dialog.lastMessageReadTime {
                                HCChatDialog.incrementUnreadCount(dialogID, transaction: transaction)
                            }
                        }
                    }
                }
                
                transaction.commit({ (result) in
                    dispatch_semaphore_signal(self.messageCreateSem)
                })
            })
        }
        else if let messageID = messageJSON["id"] {
            
            CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                let message = HCMessage.findOrCreateMessage(serverID: "\(messageID)", transaction: transaction)
                HCMessage.updateMessage(messageJSON, message: message, transaction: transaction)
                message.failed = false
                let currentUserID = HCSDKCore.sharedInstance.currentUserID()
                // update dialog unread message info
                if let dialogID = messageJSON["dialog_id"] as? String
                {
                    if message.senderID != currentUserID
                    {
                        if let dialog = HCChatDialog.findDialog(dialogID, transaction: transaction)
                        {
                            if message.receiveTime > dialog.lastMessageReadTime {
                                HCChatDialog.incrementUnreadCount(dialogID, transaction: transaction)
                            }
                        }
                    }
                }
                
                transaction.commit()
            })
        }
    }
    
    func processMessageJSONFromServer(response: [String: AnyObject]?)
    {
        if let returnedJSON = response
        {
            if let dialogType = returnedJSON["dialog_type"] as? String
            {
                if dialogType == HCSDKConstants.kMessageTypeGroup {
                    
                    if let dialogID = returnedJSON["dialog_id"] as? String
                    {
                        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                            
                            if let _ = transaction.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo: dialogID))
                            {
                                self.processChatMessageJSON(returnedJSON)
                            }
                            else {
                                
                                DialogsManager.sharedInstance.fetchDialogInfo(dialogID, completion: { (error) in
                                    
                                    if error == nil {
                                        self.processChatMessageJSON(returnedJSON)
                                    }
                                })
                            }
                        })
                    }
                }
                else if dialogType == HCSDKConstants.kMessageTypeIndividual {
                    
                    if let dialogID = returnedJSON["dialog_id"] as? String
                    {
                        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                            
                            if let _ = transaction.fetchOne(From(HCUser), Where("userID", isEqualTo: dialogID))
                            {
                                self.processChatMessageJSON(returnedJSON)
                            } else {
                                
                                //didn't find the this user locally, fetch user info
                                AppFriendsUserManager.sharedInstance.fetchUserInfo(dialogID, completion: { (response, error) in
                                    self.processChatMessageJSON(returnedJSON)
                                })
                            }
                        })
                    }
                }
                else if dialogType == HCSDKConstants.kMessageTypeSystem {
                    
                    if let data = returnedJSON["meta_data"] as? NSDictionary
                    {
                        self.processMessageMetadata(data)
                        self.processChatMessageJSON(returnedJSON)
                    }
                }
            }
            
        }
    }
    
    
    func processMessageMetadata(metadata: NSDictionary)
    {
        var action = ""
        var actionType = ""
        
        if let systemAction = metadata["action"] as? String
        {
            action = systemAction
        }
        if let systemActionType = metadata["action_type"] as? String
        {
            actionType = systemActionType
        }
        
        if action == "g"
        {
            if let dialogID = metadata["dialog"] as? String
            {
                DialogsManager.sharedInstance.fetchDialogInfo(dialogID, completion: nil)
            }
        }
    }
}
