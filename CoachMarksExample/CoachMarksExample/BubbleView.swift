//
//  BubbleView.swift
//  CoachMarksExample
//
//  Created by Darin Doria on 6/13/17.
//  Copyright © 2017 Darin Doria. All rights reserved.
//

import Foundation
import UIKit

let ARROW_SIZE = 6
let ARROW_SPACE = 6
let PADDING = 8.0
let RADIUS = 6.0

class BubbleView: UIView {
    enum ArrowPosition {
        case top
        case bottom
        case left
        case right
    }
    
    var arrowOffset: CGFloat = 0.0
    var arrowPosition: ArrowPosition = .top
    var title: String?
    var text: String
    var color: UIColor = UIColor.white
    var bouncing: Bool = true
    var animationShouldStop: Bool = false
    var attachedFrame: CGRect = CGRect.zero
    
    // can I check project's default font???
    var font: UIFont = UIFont.systemFont(ofSize: 14)

    init(frame: CGRect, text: String) {
        self.text = text
        self.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, title: String, text: String, arrowPosition: ArrowPosition, color: UIColor?, font: UIFont? = nil) {
        self.init(frame: frame, text: text)
        
        if color != nil {
            self.color = color!
        }
        
        if font != nil {
            self.font = font!
        }
        
        self.attachedFrame = frame
        self.title = title
        self.arrowPosition = arrowPosition
        self.backgroundColor = UIColor.clear
        
        self.frame = calulateFrame(with: self.font)
        fixFrameIfOutOfBounds()
        
        // Make it pass touch events through to the CoachMarksView
        isUserInteractionEnabled = false
        
        // Calculate and position text
        let actualXPosition = self.offsets.width + CGFloat((PADDING * 1.5))
        let actualYPosition = self.offsets.height + CGFloat((PADDING * 1.25))
        let actualWidth = self.frame.size.width - actualXPosition - CGFloat((PADDING * 1.5))
        let actualHeight = self.frame.size.height - actualYPosition - CGFloat((PADDING * 1.2))
        
        let label = UILabel(frame: CGRect(x: actualXPosition, y: actualYPosition, width: actualWidth, height: actualHeight))
        label.font = self.font
        label.textColor = UIColor.black
        label.alpha = 0.9
        label.text = title
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

    func size(with font: UIFont) -> CGSize {
        
        let frame = UIApplication.shared.keyWindow!.frame
        var widthDelta = CGFloat(0)
        
        if (arrowPosition == .left || arrowPosition == .right) {
            widthDelta = CGFloat(ARROW_SIZE)
        }
        
        let boundingSize = CGSize(width: frame.size.width - widthDelta - CGFloat(PADDING * 3.0), height: CGFloat.greatestFiniteMagnitude)
        let result = NSString(string: title!).boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).size
        
        return CGSize(width: result.width + CGFloat(PADDING * 3.0), height: result.height + CGFloat(PADDING * 2.5))
    }

    func calulateFrame(with font: UIFont) -> CGRect {
        // Calculate bubble position
        var x = attachedFrame.origin.x
        var y = attachedFrame.origin.y
      
        let size = self.size(with: font)

        var widthDelta = 0, heightDelta = 0

        if (arrowPosition == .left || arrowPosition == .right) {
            y += attachedFrame.size.height / 2 - size.height / 2
            x += arrowPosition == .left ? CGFloat(ARROW_SPACE) + attachedFrame.size.width : -(CGFloat(ARROW_SPACE) * 2 + size.width)
            widthDelta = ARROW_SIZE
        } else {
            x += attachedFrame.size.width / 2 - size.width / 2
            y += arrowPosition == .top ? CGFloat(ARROW_SPACE) + attachedFrame.size.height : -(CGFloat(ARROW_SPACE) * 2 + size.height)
            heightDelta = ARROW_SIZE
        }

        return CGRect(x: x, y: y, width: size.width + CGFloat(widthDelta), height: size.height + CGFloat(heightDelta))
    }

    var offsets: CGSize {
        return CGSize(width: arrowPosition == .left ? ARROW_SIZE : 0, height: arrowPosition == .top ? ARROW_SIZE : 0)
    }

    // MARK:- Drawing & Animation
    override func draw(_ rect: CGRect) {

        guard let ctx = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            print("BubbleView#draw Couldn't get graphics context")
            return
        }

        ctx.saveGState()

        let size = self.size(with: font)
        
        let clipPath = UIBezierPath(roundedRect: CGRect(x: offsets.width, y: offsets.height, width: size.width, height: size.height), cornerRadius: CGFloat(RADIUS))
      
        ctx.addPath(clipPath.cgPath)
        ctx.setFillColor(color.cgColor)
        ctx.closePath()
        ctx.fillPath()
        color.set()

        // Tip of the arrow needs to be centered under highlighted region
        // This center area is always arrow size divided by 2
        let center = ARROW_SIZE / 2

        //  points used to draw arrow
        //  Wide Arrow --> x = center + - ArrowSize
        //  Skinny Arrow --> x = center + - center
        //  Normal Arrow -->
        let startPoint = CGPoint(x: center - ARROW_SIZE, y: ARROW_SIZE)
        let midPoint = CGPoint(x: center, y: 0)
        let endPoint = CGPoint(x: center + ARROW_SIZE, y: ARROW_SIZE)

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.addLine(to: midPoint)
        path.addLine(to: startPoint)
        
        let arrowSize = CGFloat(ARROW_SIZE)
        let halfArrowSize = arrowSize / CGFloat(2.0)
        
        var trans: CGAffineTransform!
        var rot: CGAffineTransform?
        
        if (arrowPosition == .top) {
            trans = CGAffineTransform(translationX: size.width/2 - halfArrowSize + arrowOffset, y: 0)
        } else if (arrowPosition == .bottom) {
            rot = CGAffineTransform(rotationAngle: CGFloat.pi)
            trans = CGAffineTransform(translationX: size.width/2 + halfArrowSize + arrowOffset, y: size.height + arrowSize)
        } else if (arrowPosition == .left) {
            rot = CGAffineTransform(rotationAngle: CGFloat.pi * CGFloat(1.5))
            trans = CGAffineTransform(translationX: 0, y: (size.height + arrowSize) / 2)
        } else if (arrowPosition == .right) {
            rot = CGAffineTransform(rotationAngle: CGFloat.pi * CGFloat(0.5))
            trans = CGAffineTransform(translationX: size.width + arrowSize, y: (size.height - arrowSize) / 2)
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

    func animate() {
        UIView.animate(withDuration: 2.0, delay: 0.3, options: [.repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -5)
        }, completion: nil)
    }
    
    /**
     Check if bubble is going off the screen using the position and size. If it is, return true
     */
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
            let flippedFrame = calulateFrame(with: font)
            y = flippedFrame.origin.y
            height = flippedFrame.size.height
        } else if (arrowPosition == .bottom && y < 0) {
            arrowPosition = .top
            
            // Restart the entire process
            let flippedFrame = calulateFrame(with: font)
            y = flippedFrame.origin.y
            height = flippedFrame.size.height
        }
        
        frame = CGRect(x: x, y: y, width: width, height: height)
    }
}
