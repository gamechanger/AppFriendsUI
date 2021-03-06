//
//  HCMessageAttachment.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/19/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

// objc compatible type

@objc public enum HCMessageAttachmentType: Int {
    case Image
    case Video
    case Gif
    
    public func name() -> String {
        switch self {
        case .Image: return "image"
        case .Video: return "video"
        case .Gif: return "gif"
        }
    }
}

public class HCVideoAttachment: HCMessageAttachment {
    
    var thumbnail: String?
    
    public override class func getAttachmentFromMessage(dataString customData: String) -> HCVideoAttachment?
    {
        if let data = HCUtils.dictionaryFromJsonString(customData)
        {
            if let attachmentInfo = data["attachment"] as? [String: AnyObject]
            {
                let attachment = HCVideoAttachment()
                attachment.attachmentType = attachmentInfo["type"] as? String
                if attachment.attachmentType == HCMessageAttachmentType.Video.name()
                {
                    if let payload = attachmentInfo["payload"] as? [String: AnyObject] {
                        
                        if let url = payload["url"] as? String{
                            attachment.url = url
                        }
                        
                        if let thumbnail = payload["thumbnail"] as? String{
                            attachment.thumbnail = thumbnail
                        }
                    }
                }
                
                return attachment
            }
        }
        return nil
    }
}

public class HCMessageAttachment: NSObject {
    
    var attachmentType: String?
    var url: String?

    public class func getAttachmentFromMessage(dataString customData: String) -> HCMessageAttachment?
    {
        if let data = HCUtils.dictionaryFromJsonString(customData)
        {
            if let attachmentInfo = data["attachment"] as? [String: AnyObject]
            {
                let attachment = HCMessageAttachment()
                attachment.attachmentType = attachmentInfo["type"] as? String
                if attachment.attachmentType == HCMessageAttachmentType.Image.name()
                {
                    if let payload = attachmentInfo["payload"] as? [String: AnyObject] {
                        
                        if let url = payload["url"] as? String{
                            attachment.url = url
                        }
                    }
                }
                
                return attachment
            }
        }
        return nil
    }
}
