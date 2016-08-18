//
//  HCChannelTableViewCell.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

public class HCChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var channelImageView: UIImageView!
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
