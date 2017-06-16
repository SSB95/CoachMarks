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

    let arrowPosition: ArrowPosition = .top
    var title: String?
    var text: String
    var color: UIColor = UIColor.white
    var bouncing: Bool = true
    var animationShouldStop: Bool = false

    // can I check project's default font???
    var font: UIFont

    init(frame: CGRect, text: String) {
        self.text = text
        self.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        super.init(frame: frame)
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
        var width = CGFloat(PADDING * 3)
        var height = CGFloat(PADDING * 2.5)
        let frame = UIApplication.shared.keyWindow?.frame

        if (title != nil && frame != nil && (arrowPosition == .left || arrowPosition == .right)) {
            let widthDelta = CGFloat(ARROW_SIZE)
            let boundingSize = CGSize(width: frame!.size.width - widthDelta - CGFloat(PADDING * 3), height: CGFloat(Float.greatestFiniteMagnitude))
            let result = title!.boundingRect(with: boundingSize, options: .usesDeviceMetrics, attributes: [NSFontAttributeName: font], context: nil)

            width += result.width
            height += result.height
        }

        return CGSize(width: width, height: height)
    }

    func calulateFrame(with font: UIFont) -> CGRect {
        // Calculate bubble position
        var x = frame.origin.x
        var y = frame.origin.y

        let size = self.size(with: font)

        var widthDelta = 0, heightDelta = 0

        if (arrowPosition == .left || arrowPosition == .right) {
            y += frame.size.height / 2 - size.height / 2
            x += (arrowPosition == .left ? CGFloat(ARROW_SPACE) + frame.size.height : -(CGFloat(ARROW_SPACE) * 2 + size.width))
            widthDelta = ARROW_SIZE
        } else {
            x += frame.size.height / 2 - size.height / 2
            y += (arrowPosition == .left ? CGFloat(ARROW_SPACE) + frame.size.height : -(CGFloat(ARROW_SPACE) * 2 + size.width))
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

        let clipPath = UIBezierPath(roundedRect: CGRect(x: offsets.width, y: offsets.height, width: size.width, height: size.height), cornerRadius: CGFloat(RADIUS)).cgPath

        ctx.addPath(clipPath)
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
    }

    func animate() {
        UIView.animate(withDuration: 2.0, delay: 0.3, options: [.repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -5)
        }, completion: nil)
    }
}
