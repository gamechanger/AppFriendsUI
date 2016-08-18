// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HCChatDialog.swift instead.

import Foundation
import CoreData

public enum HCChatDialogAttributes: String {
    case createTime = "createTime"
    case customData = "customData"
    case dialogID = "dialogID"
    case lastMessageText = "lastMessageText"
    case lastMessageTime = "lastMessageTime"
    case title = "title"
    case type = "type"
}

public enum HCChatDialogRelationships: String {
    case members = "members"
}

public class _HCChatDialog: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HCChatDialog"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _HCChatDialog.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var createTime: NSDate?

    @NSManaged public
    var customData: String?

    @NSManaged public
    var dialogID: String?

    @NSManaged public
    var lastMessageText: String?

    @NSManaged public
    var lastMessageTime: NSDate?

    @NSManaged public
    var title: String?

    @NSManaged public
    var type: String?

    // MARK: - Relationships

    @NSManaged public
    var members: NSSet

}

extension _HCChatDialog {

    func addMembers(objects: NSSet) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as Set<NSObject>)
        self.members = mutable.copy() as! NSSet
    }

    func removeMembers(objects: NSSet) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as Set<NSObject>)
        self.members = mutable.copy() as! NSSet
    }

    func addMembersObject(value: HCUser) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.members = mutable.copy() as! NSSet
    }

    func removeMembersObject(value: HCUser) {
        let mutable = self.members.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.members = mutable.copy() as! NSSet
    }

}

