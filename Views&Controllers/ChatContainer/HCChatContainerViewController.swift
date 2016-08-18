//
//  HCChatContainerViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/9/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Google_Material_Design_Icons_Swift

public class HCChatContainerViewController: HCBaseViewController, HCGroupCreatorViewControllerDelegate {
    
    public static let channelTabTitle = "Channels"
    public static let dialogsTabTitle = "Dialogs"
    public static let contactsTabTitle = "Contacts"
    
    let channelsList = HCChannelsListViewController()
    let dialogsList = HCDialogsListViewController()
    let contactsList = HCContactsViewController()
    
    weak var _segmentView: SMSegmentView!
    @IBOutlet weak var contentContainer: UIView!
    
    var currentDisplayingVC: UIViewController? = nil
    
    private var _tabs = [HCChatContainerViewController.channelTabTitle, HCChatContainerViewController.dialogsTabTitle, HCChatContainerViewController.contactsTabTitle]
    
    public init(tabs: [String]) {
        _tabs = tabs
        super.init(nibName: "HCChatContainerViewController", bundle: HCUtils.xibBundle())
    }
    
    required public init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.addSegmentedControler()
        
        self.contentContainer.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = HCColorPalette.chatBackgroundColor
        
        // close button
        let closeItem = UIBarButtonItem(image: nil, style: .Plain, target: self, action: #selector(HCChatContainerViewController.close))
        closeItem.setGMDIcon(GMDType.GMDClose, iconSize: 20)
        self.navigationItem.leftBarButtonItem = closeItem
        self.navigationItem.leftBarButtonItem?.tintColor = HCColorPalette.navigationBarIconColor
        
        // more button
        let moreItem = UIBarButtonItem(image: nil, style: .Plain, target: self, action: #selector(HCChatContainerViewController.moreButtonTapped))
        moreItem.setGMDIcon(GMDType.GMDMoreVert, iconSize: 20)
        self.navigationItem.rightBarButtonItem = moreItem
        self.navigationItem.rightBarButtonItem?.tintColor = HCColorPalette.navigationBarIconColor
        
        self.switchTabs(_segmentView)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.dismissVC(completion: nil)
    }
    
    func moreButtonTapped() {
        
        let moreActionPopup = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        moreActionPopup.addAction(UIAlertAction(title: "Create a Group", style: .Default, handler: {[weak self] (action) in
            let groupCreateVC = HCGroupCreatorViewController()
            groupCreateVC.delegate = self
            let nav = UINavigationController(rootViewController: groupCreateVC)
            self?.presentVC(nav)
        }))
        moreActionPopup.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        self.presentVC(moreActionPopup)
    }
    
    func addSegmentedControler() {
        
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = HCColorPalette.SegmentSelectorOnBgColor!
        appearance.segmentOffSelectionColour = HCColorPalette.SegmentSelectorOffBgColor
        appearance.titleOnSelectionColour = HCColorPalette.SegmentSelectorOnTextColor
        appearance.titleOffSelectionColour = HCColorPalette.SegmentSelectorOffTextColor
        appearance.titleOnSelectionFont = HCFont.SegmentSelectorFont
        appearance.titleOffSelectionFont = HCFont.SegmentSelectorFont
        appearance.contentVerticalMargin = 5.0
        
        let segmentFrame = CGRectMake(0, 0, 240, 26)
        let segmentView = SMSegmentView(frame: segmentFrame, dividerColour: UIColor.clearColor(), dividerWidth: 1.0, segmentAppearance: appearance)
        segmentView.layer.borderColor = HCColorPalette.SegmentSelectorOnBgColor!.CGColor
        segmentView.layer.borderWidth = 1
        
        
        for (_, tabTitle) in _tabs.enumerate()
        {
            var tabImage: UIImage? = nil
            
            if _tabs.count < 3
            {
                if tabTitle == HCChatContainerViewController.channelTabTitle {
                    tabImage = UIImage.fontAwesomeIconWithName(FontAwesome.Hashtag, textColor: UIColor.whiteColor(), size: CGSizeMake(25, 25))
                }
                else if tabTitle == HCChatContainerViewController.dialogsTabTitle {
                    tabImage = UIImage.fontAwesomeIconWithName(FontAwesome.ListUL, textColor: UIColor.whiteColor(), size: CGSizeMake(25, 25))
                }
                else if tabTitle == HCChatContainerViewController.contactsTabTitle {
                    tabImage = UIImage.fontAwesomeIconWithName(FontAwesome.Comments, textColor: UIColor.whiteColor(), size: CGSizeMake(25, 25))
                }
            }
            
            segmentView.addSegmentWithTitle(tabTitle, onSelectionImage: tabImage, offSelectionImage: tabImage)
            
        }
        
        segmentView.selectedSegmentIndex = 0
        segmentView.autoresizingMask = .FlexibleWidth
        
        _segmentView = segmentView
        
        segmentView.addTarget(self, action: #selector(HCChatContainerViewController.switchTabs(_:)), forControlEvents: .ValueChanged)
        
        self.navigationItem.titleView = segmentView
    }
    
    // MARK: switch tabs
    
    func switchTabs(segmentView: SMSegmentView) {
        
        if segmentView.selectedSegmentIndex == _tabs.indexOf(HCChatContainerViewController.dialogsTabTitle)
        {
            removeVC(currentDisplayingVC)
            displayDialogsList()
        }
        else if segmentView.selectedSegmentIndex == _tabs.indexOf(HCChatContainerViewController.channelTabTitle)
        {
            removeVC(currentDisplayingVC)
            displayChannelsList()
        }
        else if segmentView.selectedSegmentIndex == _tabs.indexOf(HCChatContainerViewController.contactsTabTitle)
        {
            removeVC(currentDisplayingVC)
            displayContactsList()
        }
    }
    
    func displayChannelsList() {
        
        self.addVC(channelsList)
    }
    
    func displayDialogsList() {
        
        self.addVC(dialogsList)
    }
    
    func displayContactsList() {
        
        self.addVC(contactsList)
    }
    
    func addVC(contentVC: UIViewController) {
        
        if isViewLoaded() {
            contentVC.willMoveToParentViewController(self)
            addChildViewController(contentVC)
            contentVC.view.frame = self.contentContainer.bounds
            self.contentContainer.addSubview(contentVC.view)
            currentDisplayingVC = contentVC
            contentVC.didMoveToParentViewController(self)
        }
    }
    
    func removeVC(contentVC: UIViewController?) {
        guard let vc = contentVC else { return }
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    // MARK: HCGroupCreatorViewControllerDelegate
    
    public func usersSelected(users: [String]) {
        
        self.dismissVC { 
            
            // create group dialog here
            self.showLoading("")
            DialogsManager.sharedInstance.createGroupDialog(users, completion: { (response, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                } else {
                    self.hideHUD()
                    if let json = response {
                        let dialogID = json["id"] as! String
                        let groupChatVC = HCDialogChatViewController(dialog: dialogID)
                        self.navigationController?.pushViewController(groupChatVC, animated: true)
                    }
                }
                
            })
        }
    }
    
    public func closeButtonTapped(selectVC: HCGroupCreatorViewController) {
        
        self.dismissVC(completion: nil)
    }
}
