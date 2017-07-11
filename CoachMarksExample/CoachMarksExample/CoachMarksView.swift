//
//  CoachMarksView.swift
//  CoachMarksExample
//
//  Created by Tulio Troncoso on 6/15/17.
//  Copyright © 2017 Darin Doria. All rights reserved.
//

import Foundation
import UIKit

let kAnimationDuration = 0.3
let kCutoutRadius = 2.0
let kMaxLblWidth = 230.0
let kLblSpacing = 35.0

protocol CoachMarksViewDelegate: class {
    func coachMarksView(_ coachMarksView: CoachMarksView, willNavigateTo index: Int)
    func coachMarksView(_ coachMarksView: CoachMarksView, didNavigateTo index: Int)
    func coachMarksViewWillCleanup(_ coachMarksView: CoachMarksView)
    func coachMarksViewDidCleanup(_ coachMarksView: CoachMarksView)
    func didTap(at index: Int)
}

class CoachMarksView: UIView {
    
    typealias CoachMark = [String:Any]
    
    var focusView: FocusView?
    var bubble: BubbleView?
    
    var shapeLayerMask: CAShapeLayer
    var markIndex: Int = 0
//    var lblContinue: UILabel
    weak var delegate: CoachMarksViewDelegate?
    var coachMarks: [CoachMark]
    var maskColor: UIColor = UIColor.white
    var animationDuration: CGFloat = 0.3
    var cutoutRadius: CGFloat = CGFloat(kCutoutRadius)
    var maxLblWidth: CGFloat = CGFloat(kMaxLblWidth)
    var lblSpacing: CGFloat = CGFloat(kLblSpacing)
    var useBubbles: Bool = true
    
    init(frame: CGRect, coachMarks: [CoachMark]) {
        
        self.coachMarks = coachMarks
        self.shapeLayerMask = CAShapeLayer()
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        // Shape layer mask
        shapeLayerMask.fillRule = kCAFillRuleEvenOdd
        shapeLayerMask.fillColor = UIColor(white: 0.0, alpha: 0.8).cgColor
        layer.addSublayer(shapeLayerMask)
        
        // Capture touches
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userDidTap(_:)))
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(userDidTap(_:)))
        swipeGestureRecognizer.direction = [.left, .right]
        addGestureRecognizer(swipeGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)

        // Hide until invoked
        isHidden = true
    }
    
    // MARK: Cutout Modify
    func setCutout(to rect: CGRect, with shape: String) {
        // Define shape
        let maskPath = UIBezierPath(rect: bounds)
        let cutoutPath: UIBezierPath
        
        if (shape == "circle") {
            cutoutPath = UIBezierPath(ovalIn: rect)
        } else if (shape == "square") {
            cutoutPath = UIBezierPath(rect: rect)
        } else {
            cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: cutoutRadius)
        }
        
        maskPath.append(cutoutPath)
        
        // Set the new path
        shapeLayerMask.path = maskPath.cgPath
        
    }
    
    func animateCutout(to rect: CGRect, with shape: String) {
        // Define shape
        let maskPath = UIBezierPath(rect: bounds)
        let cutoutPath: UIBezierPath
        
        if shape == "circle" {
            cutoutPath = UIBezierPath(ovalIn: rect)
        } else if shape == "square" {
            cutoutPath = UIBezierPath(rect: rect)
        } else {
            cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: cutoutRadius)
        }
        
        maskPath.append(cutoutPath)
        
        // Animate it
        var anim = CABasicAnimation(keyPath: "path")
        anim.delegate = self
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim.duration = CFTimeInterval(animationDuration)
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.fromValue = shapeLayerMask.mask
        anim.toValue = maskPath.cgPath
        shapeLayerMask.add(anim, forKey: "path")
        shapeLayerMask.path = maskPath.cgPath
    }
 
    // MARK: Mask Color
    func setMaskColor(color: UIColor) {
        maskColor = color
        shapeLayerMask.fillColor = maskColor.cgColor
    }

    func userDidTap(_ recognizer: UIGestureRecognizer) {
        delegate?.didTap(at: markIndex)
        
        // Go to the next coach mark
         goToCoachmark(index: markIndex+1)
    }
    
    func start() {
        // Fade in self
        alpha = 0.0
        isHidden = false
        UIView.animate(withDuration: Double(self.animationDuration), animations: {
            self.alpha = 1.0
        }, completion: { finished in
            self.goToCoachmark(index: 0)
        })
    }
    
    func goToCoachmark(index: Int) {
        // Out of bounds
        guard index < coachMarks.count else {
            cleanup()
            return
        }
        
        // Current index
        markIndex = index
        
        // Delegate
        delegate?.coachMarksView(self, willNavigateTo: markIndex)
        
        // Coach mark definition
        let coachMark = coachMarks[index]
        let markRect = coachMark["rect"] as! CGRect
        let shape = coachMark["shape"] as! String
        if (useBubbles) {
            animateNextBubble()
        }
        
        if (markIndex == 0) {
            let center = CGPoint(x: floor(CGFloat(markRect.origin.x + (markRect.size.width / 2.0))),
                                 y: floor(CGFloat(markRect.origin.y + (markRect.size.height / 2.0))))
            let centerZero = CGRect(origin: center, size: .zero)
            setCutout(to: centerZero, with: shape)
        }
        
        // Animate the cutout
        animateCutout(to: markRect, with: shape)
        
        // Animate swipe gesture
        showSwipeGesture()
    }
    
    func showSwipeGesture() {

        let coachMarkInfo = coachMarks[markIndex]
        let frame = coachMarkInfo["rect"] as! CGRect
        let shouldAnimateSwipe = coachMarkInfo["swipe"] as? Bool ?? true
        
        var direction: FocusView.FocusSwipeDirection = .leftToRight
        if let d = coachMarkInfo["direction"] as? FocusView.FocusSwipeDirection {
            direction = d
        }
        
        // If next animation doesn't need swipe, remove current swiping circle if one exists
        if focusView != nil {
            UIView.animate(withDuration: 0.6, delay: 0.3, options: [], animations: {
                self.focusView!.alpha = 0.0
            }, completion: { (finished) in
                self.focusView!.removeFromSuperview()
            })
        }
        
        // Create an animating focus view and animate it
        if (shouldAnimateSwipe) {
            focusView = FocusView(frame: frame)
            
            if (!subviews.contains(focusView!)) {
                addSubview(focusView!)
            }
        }
        
        focusView?.swipeDirection = direction
        
        focusView?.swipe(in: frame)
        
    }
    
    func animateNextBubble() {

        // Get current coach mark info
        let coachMarkInfo = coachMarks[markIndex]
        let markCaption = coachMarkInfo["caption"] as? String
        let frame = coachMarkInfo["rect"] as! CGRect
        let poi = coachMarkInfo["POI"] as? CGRect
        let font = coachMarkInfo["font"] as? UIFont
        
        // Remove previous bubble
        if (bubble != nil) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.bubble!.alpha = 0.0
            }, completion: nil)
        }
        
        // Return if no text for bubble
        if (markCaption != nil && !markCaption!.isEmpty) {
            return
        }
        
        // Create Bubble
        // Use POI if available, else use the cutout frame
        bubble = BubbleView(frame: poi ?? frame, text: markCaption!)
        bubble!.font = font ?? bubble!.font
        bubble!.alpha = 0.0
        addSubview(bubble!)
        
        // Fade in & bounce animation
        UIView.animate(withDuration: 0.8, delay: 0.3, options: [], animations: {
            self.bubble!.alpha = 1.0
            self.bubble!.animate()
        }, completion: nil)
    }
    
    
    func cleanup() {

        delegate?.coachMarksViewWillCleanup(self)
        
        weak var weakSelf = self
        
        // Animate & remove from super
        UIView.animate(withDuration: 0.6, delay: 0.3, options: [], animations: {
            self.alpha = 0.0
            self.focusView?.alpha = 0.0
            self.bubble?.alpha = 0.0
        }, completion: { (finished) in
            weakSelf?.focusView?.animationShouldStop = true
            weakSelf?.bubble?.animationShouldStop = true
            weakSelf?.focusView?.removeFromSuperview()
            weakSelf?.bubble?.removeFromSuperview()
            weakSelf?.removeFromSuperview()
            weakSelf?.delegate?.coachMarksViewDidCleanup(weakSelf!)
        })
        
    }

}

extension CoachMarksView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        delegate?.coachMarksView(self, didNavigateTo: markIndex)
    }
}
