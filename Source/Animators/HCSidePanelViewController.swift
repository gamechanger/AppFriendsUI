//
//  HCSidePanelViewController.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import EZSwiftExtensions

public class HCSidePanelViewController: UIViewController {

    let panelContainerView = UIView()
    let panelDimissView = UIView()
    var slideDirection: HCSideDirection = .Right
    private var _animator: HCSidePanelAnimator
    private var _contentVC: UIViewController
    
    public init(animator: HCSidePanelAnimator, contentVC: UIViewController) {
        _animator = animator
        _contentVC = contentVC
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = _animator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clearColor()

        let dismissViewWidth = self.view.w - HCConstants.sidePanelWindowWidth
        
        if slideDirection == .Right {
            panelContainerView.frame = CGRectMake(0, 0, HCConstants.sidePanelWindowWidth, self.view.h)
            panelDimissView.frame = CGRectMake(HCConstants.sidePanelWindowWidth, 0, dismissViewWidth, self.view.h)
            panelDimissView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleLeftMargin]
        }
        else {
            panelContainerView.frame = CGRectMake(dismissViewWidth, 0, HCConstants.sidePanelWindowWidth, self.view.h)
            panelDimissView.frame = CGRectMake(0, 0, dismissViewWidth, self.view.h)
            panelDimissView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleRightMargin]
        }
        panelContainerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        panelContainerView.backgroundColor = UIColor.redColor()
        
        panelDimissView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(panelContainerView)
        self.view.addSubview(panelDimissView)
        self.addVC(_contentVC)
        
        self.panelDimissView.addTapGesture { [weak self](tapGesture) in
            
            self?.dismissVC(completion: nil)
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addVC(contentVC: UIViewController) {
        
        if isViewLoaded() {
            contentVC.willMoveToParentViewController(self)
            addChildViewController(contentVC)
            contentVC.view.frame = self.panelContainerView.bounds
            self.panelContainerView.addSubview(contentVC.view)
            contentVC.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            contentVC.didMoveToParentViewController(self)
        }
    }
    
    func removeVC(contentVC: UIViewController?) {
        guard let vc = contentVC else { return }
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
}
