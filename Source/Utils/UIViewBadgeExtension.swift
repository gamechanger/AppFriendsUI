//
//  UIViewBadgeExtension.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/22/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

private var hcBadgeCountAssociationKey: UInt16 = 19317 // just a random number to use as the key
private let hcBadgeViewTag = 19317
private let hcBadgeSize = CGSizeMake(15, 15)

extension UIView {
    
    var badge: String? {
        get {
            return objc_getAssociatedObject(self, &hcBadgeCountAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &hcBadgeCountAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            
            if newValue == "0" {
                setBadgeText(nil)
            }
            else {
                setBadgeText(newValue)
            }
        }
    }
    
    private func setBadgeText(text: String?) {
        
        // add badge label if needed
        
        var existingBadgeLabel = self.viewWithTag(hcBadgeViewTag) as? UILabel
        if existingBadgeLabel == nil
        {
            let badgeLabel = UILabel()
            badgeLabel.tag = hcBadgeViewTag
            let height = max(20, Double(hcBadgeSize.height) + 5.0)
            let width = max(height, Double(hcBadgeSize.width) + 5.0)
            
            let x = CGRectGetWidth(self.frame) - CGFloat((width / 2.0))
            let y = CGFloat(-(height / 2.0))
            
            badgeLabel.frame = CGRectMake(x, y, CGFloat(width), CGFloat(height))
            self.setupBadgeStyle(badgeLabel)
            badgeLabel.text = text
            self.addSubview(badgeLabel)
            existingBadgeLabel = badgeLabel
        }
        else {
            existingBadgeLabel?.text = text
        }
        
        if text == nil || text == "0" {
            existingBadgeLabel?.hidden = true
        }
        else
        {
            existingBadgeLabel?.hidden = false
        }
        
        
    }
    
    private func setupBadgeStyle(badgeLabel: UILabel) {
        badgeLabel.textAlignment = .Center
        badgeLabel.backgroundColor = HCColorPalette.badgeBackgroundColor
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
        badgeLabel.font = UIFont.systemFontOfSize(12)
        badgeLabel.textAlignment = .Center
        //badgeLabel.sizeToFit()
        badgeLabel.clipsToBounds = true
    }
    
}