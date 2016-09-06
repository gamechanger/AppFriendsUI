//
//  InviteUserViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore

@objc protocol InviteUserViewControllerDelegate {
    
    func usersSelected(users: [String])
}

class InviteUserViewController: HCUserSearchViewController {

    weak var delegate: InviteUserViewControllerDelegate? = nil
    
    var selectedUserIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(InviteUserViewController.doneButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.delegate?.usersSelected(selectedUserIDs)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.backgroundColor = self.view.backgroundColor
        
        if let user = self.userAtIndexPath(indexPath), let userID = user.userID
        {
            if selectedUserIDs.contains(userID) {
                
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let user = self.userAtIndexPath(indexPath), let userID = user.userID
        {
            if selectedUserIDs.contains(userID) {
                selectedUserIDs.removeObject(userID)
            }
            else {
                selectedUserIDs.append(userID)
            }
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}
