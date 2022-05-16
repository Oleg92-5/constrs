//
//  AnimController.swift
//  constrs
//
//  Created by Олег Рубан on 24.03.2022.
//

import UIKit

class AnimController: NSObject, UIViewControllerAnimatedTransitioning {
    var imageView: UIImageView
    var imageFrame: CGRect
    
    var isDismissing = false
    
    init(imageView: UIImageView, imageFrame: CGRect) {
        self.imageView = imageView
        self.imageFrame = imageFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = transitionContext.viewController(forKey: .from),
              let toVc = transitionContext.viewController(forKey: .to) else {
                  return
              }

        let controller = !isDismissing ? toVc : fromVc
        let targetView = controller.view!
        
        
        let containerView = transitionContext.containerView
        let startFrame = transitionContext.initialFrame(for: controller)
        let finalFrame = transitionContext.finalFrame(for: controller)
        
        containerView.addSubview(targetView)
        targetView.frame = !isDismissing ? finalFrame : startFrame
        
        if !isDismissing {
            targetView.transform = .identity.scaledBy(x: imageFrame.width / finalFrame.width, y: imageFrame.height / finalFrame.height)
            targetView.center = .init(x: imageFrame.midX, y: imageFrame.midY)
            targetView.alpha = 0.0
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .curveEaseIn) {
            targetView.alpha = self.isDismissing ? 0.0 : 1.0
            
            if !self.isDismissing {
                targetView.transform = .identity
                targetView.center = .init(x: finalFrame.midX, y: finalFrame.midY)
            } else {
                targetView.transform = .identity.scaledBy(x: self.imageFrame.width / startFrame.width, y: self.imageFrame.height / startFrame.height)
                targetView.center = .init(x: self.imageFrame.midX, y: self.imageFrame.midY)
            }
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
