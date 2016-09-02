//
//  GameStarterViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

class GameStarterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tabBarImage = UIImage.fontAwesomeIconWithName(.SoccerBallO, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Game", image: tabBarImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
        
        self.hidesBottomBarWhenPushed = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // start a chat with this user
        if indexPath.row == 0 {
            
            self.performSegueWithIdentifier("WatchLiveGameSegue", sender: self)
        }
        else if indexPath.row == 1 {
            
            let storyboard = UIStoryboard(name: "ScheduleGame", bundle: nil)
            let scheduleGameVC = storyboard.instantiateViewControllerWithIdentifier("ScheduledGamesList")
            self.navigationController?.pushViewController(scheduleGameVC, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath)
        if indexPath.row == 0 {
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel!.text = "Watch Live Game"
        }
        else if indexPath.row == 1 {
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel!.text = "Games"
        }
        return cell
    }

}
