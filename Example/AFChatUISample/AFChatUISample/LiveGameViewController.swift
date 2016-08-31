//
//  LiveGameViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore

class LiveGameViewController: UIViewController {
    
    @IBOutlet weak var chatButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tabBarImage = UIImage.fontAwesomeIconWithName(.SoccerBallO, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Game", image: tabBarImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
        
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Game"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chatButtonTapped(sender: AnyObject) {
        
        let channelID = "456df29e-ff5f-494d-ba9a-f1e4127c9244"
        let channelChatVC = HCChannelChatViewController(dialog: channelID) // the dialogID has to be a channel you created
        AppFriendsUI.sharedInstance.presentVCInSidePanel(fromVC: self, showVC: channelChatVC, direction: .Left)
    }
}
