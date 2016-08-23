//
//  HCTopAlignedContentLabel.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/11/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

class HCTopAlignedContentLabel: UILabel {

    override func drawTextInRect(rect: CGRect) {
        guard self.text != nil else {
            return super.drawTextInRect(rect)
        }
        
        let attributedText = NSAttributedString.init(string: self.text!, attributes: [NSFontAttributeName : self.font])
        var newRect = rect
        newRect.size.height = attributedText.boundingRectWithSize(rect.size, options: .UsesLineFragmentOrigin, context: nil).size.height
        
        if self.numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(self.numberOfLines) * self.font.lineHeight)
        }
        super.drawTextInRect(newRect)
    }

}
