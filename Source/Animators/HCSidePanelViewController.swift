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
    
    var interactor:Interactor? = nil
    
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(HCSidePanelViewController.handlePanGesture))
        self.panelDimissView.addGestureRecognizer(panGesture)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        let percentThreshold:CGFloat = 0.3
        
        // convert x-position to side swipe progress (percentage)
        let translation = sender.translationInView(view)
        let horizontalMovement = translation.x / view.bounds.width
        let rightMovement = fmaxf(Float(horizontalMovement), 0.0)
        let rightMovementPercent = fminf(rightMovement, 1.0)
        let progress = CGFloat(rightMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.updateInteractiveTransition(progress)
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
        case .Ended:
            interactor.hasStarted = false
            if interactor.shouldFinish {
                interactor.finishInteractiveTransition()
            }else {
                interactor.cancelInteractiveTransition()
            }
        default:
            break
        }
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
