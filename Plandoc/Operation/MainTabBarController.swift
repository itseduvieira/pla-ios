//
//  MainTabBarController.swift
//  Plandoc
//
//  Created by Eduardo Vieira on 24/02/18.
//  Copyright © 2018 Plandoc. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    // MARK: - Tabbar delegate
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitioningObject()
    }
}

class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        UIView.transition(from: fromView, to: toView, duration: transitionDuration(using: transitionContext), options: UIViewAnimationOptions.transitionCrossDissolve) { finished in
            transitionContext.completeTransition(true)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
}
