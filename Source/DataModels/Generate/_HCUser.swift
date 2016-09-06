// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HCUser.swift instead.

import Foundation
import CoreData

public enum HCUserAttributes: String {
    case avatar = "avatar"
    case blocked = "blocked"
    case customData = "customData"
    case email = "email"
    case followers = "followers"
    case following = "following"
    case friends = "friends"
    case userID = "userID"
    case userName = "userName"
}

public enum HCUserRelationships: String {
    case dialogs = "dialogs"
}

public class _HCUser: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HCUser"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _HCUser.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var avatar: String?

    @NSManaged public
    var blocked: NSNumber?

    @NSManaged public
    var customData: String?

    @NSManaged public
    var email: String?

    @NSManaged public
    var followers: AnyObject?

    @NSManaged public
    var following: AnyObject?

    @NSManaged public
    var friends: AnyObject?

    @NSManaged public
    var userID: String?

    @NSManaged public
    var userName: String?

    // MARK: - Relationships

    @NSManaged public
    var dialogs: NSSet

}

extension _HCUser {

    func addDialogs(objects: NSSet) {
        let mutable = self.dialogs.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.dialogs = mutable.copy() as! NSSet
    }

    func removeDialogs(objects: NSSet) {
        let mutable = self.dialogs.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.dialogs = mutable.copy() as! NSSet
    }

    func addDialogsObject(value: HCChatDialog) {
        let mutable = self.dialogs.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.dialogs = mutable.copy() as! NSSet
    }

    func removeDialogsObject(value: HCChatDialog) {
        let mutable = self.dialogs.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.dialogs = mutable.copy() as! NSSet
    }

}

