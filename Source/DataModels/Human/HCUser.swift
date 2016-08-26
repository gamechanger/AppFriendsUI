import Foundation
import CoreStore

@objc(HCUser)
public class HCUser: _HCUser {
    
    public static func findOrCreateUser(userID: String, transaction: AsynchronousDataTransaction!) -> HCUser
    {
        var user = transaction.fetchOne(
            From(HCUser),
            Where("userID", isEqualTo: userID)
        )
        if user == nil {
            user = transaction.create(Into(HCUser))
        }
        
        user?.userID = userID
        return user!
    }
    
    public static func processUserInfo(userInfo: [String: AnyObject], transaction: AsynchronousDataTransaction!) -> HCUser?
    {
        if let userID = userInfo["id"] as? String {
            
            let user = HCUser.findOrCreateUser(userID, transaction: transaction)
            
            if let userName = userInfo["user_name"] as? String {
                user.userName = userName
            }
            if let avatar = userInfo["avatar"] as? String {
                user.avatar = avatar
            }
            if let email = userInfo["email"] as? String {
                user.email = email
            }
            if let customData = userInfo["custom_data"] as? String {
                user.customData = customData
            }
            return user
        }
        return nil
    }
}
