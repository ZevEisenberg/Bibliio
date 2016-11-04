//
//  NavigationController.swift
//  Biblio
//
//  Created by Adam on 11/4/16.
//  Copyright © 2016 Adam Tecle. All rights reserved.
//

import UIKit

public class NavigationController: UINavigationController {

   public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = HorizontalSlideAnimationController()
        animator.isPushing = (operation == .push) ? true : false
        
        return animator
    }
}
