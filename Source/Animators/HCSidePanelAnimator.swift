//
//  HCSidePanelAnimator.swift
//  AppFriendsCore
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit


class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}


@objc public enum HCSideDirection: Int {
    case Left, Right
}

public class HCSidePanelAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

    public var slideDirection: HCSideDirection = .Right
    public var presenting: Bool = true
    let interactor = Interactor()
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
        return HCConstants.sidePanelSlideAnimationDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
     
        if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
           let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        {
            let containerView = transitionContext.containerView()
            let fromView = fromVC.view
            let toView = toVC.view
            
            let panelWidth = HCConstants.sidePanelWindowWidth
            
            // find the initial position of the side panel
            var originFrameForPanel = toView.frame
            let finalFrameForPanel = toView.frame
            
            if (self.slideDirection == .Left) // slide to the left
            {
                originFrameForPanel.origin.x = fromView.frame.size.width;
            }
            else if (self.slideDirection == .Right) // slide to the right
            {
                originFrameForPanel.origin.x = -panelWidth;
            }
            
            if (presenting) { // presenting
                containerView.addSubview(toView)
                toView.frame = fromView.frame;
                toView.frame = originFrameForPanel
                UIView.animateWithDuration(HCConstants.sidePanelSlideAnimationDuration, animations: { 
                    toView.frame = finalFrameForPanel
                }, completion: { (finished) in
                    transitionContext.completeTransition(true)
                })
            }
            else { // dismissing
                
                UIView.animateWithDuration(HCConstants.sidePanelSlideAnimationDuration, animations: {
                    fromView.frame = originFrameForPanel
                }, completion: { (finished) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                })
            }
        }
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    public func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
                             sourceController source: UIViewController) ->
        UIViewControllerAnimatedTransitioning?
    {
        self.presenting = true
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.presenting = false
        return self
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
