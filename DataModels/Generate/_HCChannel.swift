// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HCChannel.swift instead.

import Foundation
import CoreData

public enum HCChannelAttributes: String {
    case channelID = "channelID"
    case customData = "customData"
    case title = "title"
}

public class _HCChannel: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HCChannel"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _HCChannel.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var channelID: String?

    @NSManaged public
    var customData: String?

    @NSManaged public
    var title: String?

    // MARK: - Relationships

}

