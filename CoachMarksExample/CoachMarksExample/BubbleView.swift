//
//  BubbleView.swift
//  CoachMarksExample
//
//  Created by Darin Doria on 6/13/17.
//  Copyright © 2017 Darin Doria. All rights reserved.
//

import Foundation
import UIKit

/// The view in charge of displaying the text around the focus area
class BubbleView: UIView {
    
    // MARK:- ArrowPosition
    
    enum ArrowPosition {
        case top
        case bottom
        case left
        case right
    }
    
    // MARK:- Properties
    
    let arrowHeight: CGFloat = 12
    
    /// Space between arrow and highlighted region
    let arrowSpace: CGFloat = 6
    
    /// Padding between text and border of bubble
    let textPadding: CGFloat = 8.0
    
    /// Corner radius of bubble
    let cornerRadius: CGFloat = 6.0
    
    /// X-offset from left
    var arrowOffset: CGFloat = 0
    
    var arrowPosition: ArrowPosition = .top
    
    var text: String?
    
    /// Color of the bubble
    var color: UIColor = UIColor.white
    var bouncing: Bool = true
    
    var attachedFrame: CGRect = CGRect.zero
    var font: UIFont = UIFont.systemFont(ofSize: 14)
    
    var animationShouldStop: Bool = false
    
    // MARK:- Init
    
    init(frame: CGRect, text: String) {
        self.text = text
        self.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, text: String, arrowPosition: ArrowPosition, color: UIColor?, font: UIFont? = nil) {
        self.init(frame: frame, text: text)
        
        if color != nil {
            self.color = color!
        }
        
        if font != nil {
            self.font = font!
        }
        
        self.text = text
        self.arrowPosition = arrowPosition
        self.backgroundColor = UIColor.clear
        
        self.attachedFrame = frame
        self.frame = bubbleViewFrame
        fixFrameIfOutOfBounds()
        
        // Make it pass touch events through to the CoachMarksView
        isUserInteractionEnabled = false
        
        // Calculate and position text
        let actualXPosition = self.offsets.width + textPadding * 1.5
        let actualYPosition = self.offsets.height + textPadding * 1.25
        let actualWidth = self.frame.size.width - actualXPosition - textPadding * 1.5
        let actualHeight = self.frame.size.height - actualYPosition - textPadding * 1.2
        
        let label = UILabel(frame: CGRect(x: actualXPosition, y: actualYPosition, width: actualWidth, height: actualHeight))
        label.font = self.font
        label.textColor = UIColor.black
        label.alpha = 0.9
        label.text = text
        label.backgroundColor = UIColor.clear
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        self.addSubview(label)
        self.setNeedsDisplay()
    }

    convenience init(attachedView view: UIView, _ text: String) {
        self.init(frame: view.frame, text: text)
    }

    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        super.init(coder: aDecoder)
    }
    
    // MARK:- Sizing
    
    /// The size of bubble
    /// - Note: This size does NOT include the arrow
    var bubbleSize: CGSize {
        
        let frame = UIApplication.shared.keyWindow!.frame
        var widthDelta = CGFloat(0)
        
        if (arrowPosition == .left || arrowPosition == .right) {
            widthDelta = CGFloat(arrowHeight)
        }
        
        let boundingSize = CGSize(width: frame.size.width - widthDelta - textPadding * 3.0, height: CGFloat.greatestFiniteMagnitude)
        let result = NSString(string: text!).boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).size
        
        return CGSize(width: result.width + textPadding * 3.0, height: result.height + textPadding * 2.5)
    }
    
    /// The frame of the entire BubbleView, including the arrow
    var bubbleViewFrame: CGRect {
        // Calculate bubble position
        var x = attachedFrame.origin.x
        var y = attachedFrame.origin.y
      
        let size = bubbleSize

        var widthDelta: CGFloat = 0, heightDelta: CGFloat = 0

        if (arrowPosition == .left || arrowPosition == .right) {
            y += attachedFrame.size.height / 2 - size.height / 2
            x += arrowPosition == .left ? arrowSpace + attachedFrame.size.width : -(arrowSpace * 2 + size.width)
            widthDelta = arrowHeight
        } else {
            x += attachedFrame.size.width / 2 - size.width / 2
            y += arrowPosition == .top ? arrowSpace + attachedFrame.size.height : -(arrowSpace * 2 + size.height)
            heightDelta = arrowHeight
        }

        return CGRect(x: x, y: y, width: size.width + widthDelta, height: size.height + heightDelta)
    }
    
    /// Offsets to account for the arrow position
    var offsets: CGSize {
        return CGSize(width: arrowPosition == .left ? arrowHeight : 0, height: arrowPosition == .top ? arrowHeight : 0)
    }

    // MARK:- Drawing & Animation
    override func draw(_ rect: CGRect) {

        guard let ctx = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            print("BubbleView#draw Couldn't get graphics context")
            return
        }

        ctx.saveGState()

        let size = bubbleSize
        
        let clipPath = UIBezierPath(roundedRect: CGRect(x: offsets.width, y: offsets.height, width: size.width, height: size.height), cornerRadius: cornerRadius)
      
        ctx.addPath(clipPath.cgPath)
        ctx.setFillColor(color.cgColor)
        ctx.closePath()
        ctx.fillPath()
        color.set()

        // Tip of the arrow needs to be centered under highlighted region
        // This center area is always arrow size divided by 2
        let center = arrowHeight / 2

        //  points used to draw arrow
        //  Wide Arrow --> x = center + - ArrowSize
        //  Skinny Arrow --> x = center + - center
        //  Normal Arrow -->
        let startPoint = CGPoint(x: center - arrowHeight, y: arrowHeight)
        let midPoint = CGPoint(x: center, y: 0)
        let endPoint = CGPoint(x: center + arrowHeight, y: arrowHeight)

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.addLine(to: midPoint)
        path.addLine(to: startPoint)
        
        let halfArrowSize = arrowHeight / CGFloat(2.0)
        
        var trans: CGAffineTransform!
        var rot: CGAffineTransform?
        
        if (arrowPosition == .top) {
            trans = CGAffineTransform(translationX: size.width/2 - halfArrowSize + arrowOffset, y: 0)
        } else if (arrowPosition == .bottom) {
            rot = CGAffineTransform(rotationAngle: CGFloat.pi)
            trans = CGAffineTransform(translationX: size.width/2 + halfArrowSize + arrowOffset, y: size.height + arrowHeight)
        } else if (arrowPosition == .left) {
            rot = CGAffineTransform(rotationAngle: CGFloat.pi * 1.5)
            trans = CGAffineTransform(translationX: 0, y: (size.height + arrowHeight) / 2)
        } else if (arrowPosition == .right) {
            rot = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
            trans = CGAffineTransform(translationX: size.width + arrowHeight, y: (size.height - arrowHeight) / 2)
        }
        
        if let rotationTransform = rot {
            path.apply(rotationTransform)
        }
        
        path.apply(trans)
        
        path.close()
        path.fill()
        path.stroke()
        ctx.restoreGState()
    }
        
    /// Start bounce animation
    func animate() {
        UIView.animate(withDuration: 2.0, delay: 0.3, options: [.repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -5)
        }, completion: nil)
    }
    
    /// Check if bubble is going off the screen using the position and size. If it is, return true
    func fixFrameIfOutOfBounds() {
        guard let window = UIApplication.shared.keyWindow?.frame else {
            print("Couldn't get app window")
            return
        }
        
        let xBounds = window.size.width
        let yBounds = window.size.height
        
        var x = frame.origin.x
        var y = frame.origin.y
        let width = frame.size.width
        var height = frame.size.height
        
        let padding = CGFloat(3.0)
        
        // Check for right-most bound
        if (x + width > xBounds) {
            arrowOffset = (x + width) - xBounds
            x = xBounds - width
        }
        
        // Check for left-most bound
        if (x < 0) {
            if (arrowOffset == 0) {
                arrowOffset = x - padding
            }
            x = 0
        }
        
        // If the content pushes us off the vertical bounds, we might have to be more
        // drastic and flip the arrow direction
        if (arrowPosition == .top && (y + height) > yBounds) {
            arrowPosition = .bottom
            
            // Restart the entire process
            let flippedFrame = bubbleViewFrame
            y = flippedFrame.origin.y
            height = flippedFrame.size.height
        } else if (arrowPosition == .bottom && y < 0) {
            arrowPosition = .top
            
            // Restart the entire process
            let flippedFrame = bubbleViewFrame
            y = flippedFrame.origin.y
            height = flippedFrame.size.height
        }
        
        frame = CGRect(x: x, y: y, width: width, height: height)
    }
}
