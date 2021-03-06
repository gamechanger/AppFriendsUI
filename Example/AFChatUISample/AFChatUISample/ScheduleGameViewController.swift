//
//  ScheduleGameViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import AppFriendsUI

struct Keys {
    static let gameTitleKey = "game_title"
    static let gameDescriptionKey = "game_description"
    static let gameOwnerKey = "game_owner"
}

class ScheduleGameViewController: BaseViewController {

    
    @IBOutlet weak var gameTitleInput: UITextField!
    @IBOutlet weak var gameDescriptionTitle: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        
        if !HCSDKCore.sharedInstance.isLogin() {
            self.showErrorWithMessage("You are not logged in to AppFriends!")
            return
        }
        
        guard let gameTitle = gameTitleInput.text where !gameTitle.isEmpty else {
            self.showErrorWithMessage("Game title is empty!")
            return
        }
        
        guard let gameDescription = gameDescriptionTitle.text where !gameDescription.isEmpty else {
            self.showErrorWithMessage("Game description is empty!")
            return
        }
        
        self.showLoading("Scheduling Game")
        
        let json = gameJSON()
        DialogsManager.sharedInstance.createGroupDialog([String](), customJSON: json) { [weak self](response, error) in
            
            if let err = error {
                self?.showErrorWithMessage(err.localizedDescription)
            }
            else {
                self?.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    func gameJSON() -> NSDictionary {
        
        let json = NSMutableDictionary()
        json[Keys.gameTitleKey] = gameTitleInput.text
        json[Keys.gameDescriptionKey] = gameDescriptionTitle.text
        if let currentID = HCSDKCore.sharedInstance.currentUserID() {
            json[Keys.gameOwnerKey] = currentID
        }
        
        return json
    }
}
