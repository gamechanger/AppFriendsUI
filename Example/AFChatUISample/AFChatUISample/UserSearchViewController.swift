//
//  UserSearchViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/28/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore
import Google_Material_Design_Icons_Swift
import FontAwesome_swift

class UserSearchViewController: HCUserSearchViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tabBarImage = UIImage.fontAwesomeIconWithName(.Search, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Search", image: tabBarImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search"
        
    }
}
