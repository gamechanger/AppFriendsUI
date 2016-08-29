//
//  HCUserTableViewCell.swift
//  Pods
//
//  Created by HAO WANG on 8/28/16.
//
//

import UIKit

class HCUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = HCColorPalette.chatBackgroundColor
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.userAvatarView.layer.masksToBounds = true
        self.userAvatarView.layer.cornerRadius = self.userAvatarView.w/2
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
