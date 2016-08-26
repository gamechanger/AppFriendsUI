import Foundation
import CoreStore
import AppFriendsCore

@objc(HCMessage)
public class HCMessage: _HCMessage {
    
    func sendingFailed() -> Bool
    {
        if self.failed == nil, let time = self.sentTime {
            // too long, timeout.
            let timePassed = NSDate().timeIntervalSinceDate(time)
            if timePassed > 60 {
                return true
            }
        }
        else if let failed = self.failed where failed == true {
            return true
        }
        else if let failed = self.failed where failed == false  {
            return false
        }
        
        return false
    }
    
    public static func findOrCreateMessage(tempID tempID: String, transaction: AsynchronousDataTransaction) -> HCMessage
    {
        if let message = transaction.fetchOne(From(HCMessage), Where("tempID", isEqualTo: tempID))
        {
            return message
        }
        else {
            
            let message = transaction.create(Into(HCMessage))
            message.tempID = tempID
            return message
        }
    }

    public static func findMessage(tempID: String, transaction: AsynchronousDataTransaction) -> HCMessage?
    {
        if let message = transaction.fetchOne(From(HCMessage), Where("tempID", isEqualTo: tempID))
        {
            return message
        }
        return nil
    }
    
    public static func updateMessage(messageJSON: NSDictionary, message: HCMessage, transaction: AsynchronousDataTransaction!)
    {
        
        if let dialogID = messageJSON["dialog_id"]
        {
            message.dialogID = dialogID as? String
        }
        
        if let sentTimeStamp = messageJSON["sent_time"]
        {
            message.sentTime = NSDate(timeIntervalSince1970: NSTimeInterval(sentTimeStamp.doubleValue/1000.0))
        }
        
        if let receiveTimeStamp = messageJSON["receive_time"]
        {
            message.receiveTime = NSDate(timeIntervalSince1970: NSTimeInterval(receiveTimeStamp.doubleValue/1000.0))
        }
        
        if let tempID = messageJSON["temp_id"]
        {
            message.tempID = tempID as? String
        }
        
        if let messageID = messageJSON["id"]
        {
            message.messageID =  "\(messageID)"
        }
        
        if let text = messageJSON["text"]
        {
            message.text = text as? String
        }
        
        if let customData = messageJSON["custom_data"]
        {
            message.customData = customData as? String
            if let data = HCUtils.dictionaryFromJsonString(customData as! String)
            {
                if let senderInfo = data["sender"] as? [String: AnyObject]
                {
                    if let avatar = senderInfo["avatar"]
                    {
                        message.senderAvatar = avatar as? String
                    }
                    if let senderID = senderInfo["id"]
                    {
                        message.senderID = senderID as? String
                    }
                    if let senderName = senderInfo["user_name"]
                    {
                        message.senderName = senderName as? String
                    }
                    HCUser.processUserInfo(senderInfo, transaction: transaction)
                }
            }
        }
        if let dialogID = messageJSON["dialog_id"] as? String
        {
            HCChatDialog.updateDialogLastMessage(dialogID, transaction: transaction)
        }
        if let metadata = messageJSON["meta_data"] as? NSDictionary
        {
            message.metadata = metadata
        }
        
        if let dialogType = messageJSON["dialog_type"] as? String
        {
            message.messageType = dialogType
            
            if dialogType == HCSDKConstants.kMessageTypeIndividual, let dialogID = messageJSON["dialog_id"] as? String
            {
                let user = HCUser.findOrCreateUser(dialogID, transaction: transaction)
                HCChatDialog.findOrCreateDialog(dialogID, members: [dialogID], dialogTitle: user.userName, dialogType: HCSDKConstants.kMessageTypeIndividual, transaction: transaction)
            }
        }
    }
    
    public static func findOrCreateMessage(serverID messageID: String, transaction: AsynchronousDataTransaction!) -> HCMessage
    {
        if let message = transaction.fetchOne(From(HCMessage), Where("messageID", isEqualTo: "\(messageID)"))
        {
            return message
        }
        else {
            
            let message = transaction.create(Into(HCMessage))
            message.messageID = messageID
            return message
        }
    }
    
    public static func createMessage(messageJSON: NSDictionary, transaction: AsynchronousDataTransaction!) -> HCMessage
    {
        let message = transaction.create(Into(HCMessage))
        self.updateMessage(messageJSON, message: message, transaction: transaction)
        
        return message
    }
    
    func messageDisplayTime() -> NSDate?
    {
        if let receiveTime = self.receiveTime {
            return receiveTime
        }else {
            return self.sentTime
        }
    }
}
