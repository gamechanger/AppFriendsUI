import Foundation
import CoreStore
import AppFriendsCore

@objc(HCChatDialog)
public class HCChatDialog: _HCChatDialog {
    
    static func findOrCreateDialog(dialogID: String, members: [String], dialogTitle: String?, dialogType: String, transaction: AsynchronousDataTransaction)
    {
        var dialog = transaction.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo: dialogID))
        if dialog == nil
        {
            dialog = transaction.create(Into(HCChatDialog))
            dialog!.createTime = NSDate()
            dialog!.lastMessageTime = NSDate()
            dialog!.type = dialogType
            dialog!.dialogID = dialogID
        }
        
        dialog!.title = dialogTitle
        
        for userID in members
        {
            let user = HCUser.findOrCreateUser(userID, transaction: transaction)
            dialog!.addMembersObject(user)
        }
        if let currentUserID = HCSDKCore.sharedInstance.currentUserID()
        {
            let user = HCUser.findOrCreateUser(currentUserID, transaction: transaction)
            dialog!.addMembersObject(user)
        }
    }
    
    static func findDialog(dialogID: String, transaction: AsynchronousDataTransaction) -> HCChatDialog?
    {
        return transaction.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo: dialogID))
    }
    
    static func createDialog(dialogID: String, members: [String], groupTitle: String?, dialogType: String, completion: ((error: NSError?) -> ())? = nil)
    {
        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
            
            if let _ = transaction.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo: dialogID))
            {
                if let complete = completion
                {
                    let err = NSError(domain: "AppFriendsError", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Group dialog with this ID already exists.", NSLocalizedFailureReasonErrorKey: " request method."])
                    complete(error: err) // group dialog already created
                }
                return
            }
            
            self.findOrCreateDialog(dialogID, members: members, dialogTitle: groupTitle, dialogType: dialogType, transaction: transaction)
            
            transaction.commit { _ in
                
                if let complete = completion
                {
                    complete(error: nil)
                }
            }
        })
    }
    
    static func groupNameFromMembers(members: [String], transaction: AsynchronousDataTransaction? = nil) -> String
    {
        var title = ""
        let currentUserID = HCSDKCore.sharedInstance.currentUserID()
        for (index, userID) in members.enumerate()
        {
            let notCurrentUser = userID != currentUserID
            var user: HCUser? = nil
            if transaction != nil
            {
                user = transaction?.fetchOne(From(HCUser), Where("userID", isEqualTo: userID))
            }else {
                user = CoreStoreManager.store()?.fetchOne(From(HCUser), Where("userID", isEqualTo: userID))
            }
            
            if notCurrentUser, let u = user
            {
                if let userName = u.userName
                {
                    title += "\(userName)"
                    if index < members.count - 1
                    {
                        title += ","
                    }
                }
            }
        }
        
        return title
    }
    
    static func updateDialogLastMessage(dialogID: String, transaction: AsynchronousDataTransaction)
    {
        let dialog = transaction.fetchOne(From(HCChatDialog), Where("dialogID", isEqualTo: dialogID))
        if let message = transaction.fetchOne(From(HCMessage), Where("dialogID", isEqualTo: dialogID), OrderBy(.Descending("receiveTime")))
        {
            dialog?.lastMessageText = message.text
            dialog?.lastMessageTime = message.receiveTime
        }
    }
}
