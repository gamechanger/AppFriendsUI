// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HCMessage.swift instead.

import Foundation
import CoreData

public enum HCMessageAttributes: String {
    case channelID = "channelID"
    case customData = "customData"
    case dialogID = "dialogID"
    case failed = "failed"
    case handled = "handled"
    case messageID = "messageID"
    case messageType = "messageType"
    case metadata = "metadata"
    case read = "read"
    case receiveTime = "receiveTime"
    case senderAvatar = "senderAvatar"
    case senderID = "senderID"
    case senderName = "senderName"
    case sentTime = "sentTime"
    case tempID = "tempID"
    case text = "text"
}

public class _HCMessage: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HCMessage"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _HCMessage.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var channelID: String?

    @NSManaged public
    var customData: String?

    @NSManaged public
    var dialogID: String?

    @NSManaged public
    var failed: NSNumber?

    @NSManaged public
    var handled: NSNumber?

    @NSManaged public
    var messageID: String?

    @NSManaged public
    var messageType: String?

    @NSManaged public
    var metadata: AnyObject?

    @NSManaged public
    var read: NSNumber?

    @NSManaged public
    var receiveTime: NSDate?

    @NSManaged public
    var senderAvatar: String?

    @NSManaged public
    var senderID: String?

    @NSManaged public
    var senderName: String?

    @NSManaged public
    var sentTime: NSDate?

    @NSManaged public
    var tempID: String?

    @NSManaged public
    var text: String?

    // MARK: - Relationships

}

