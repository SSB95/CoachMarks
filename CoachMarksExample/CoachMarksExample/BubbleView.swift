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
let PADDING = 8.0

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
	
	func sizeWithFont() -> CGSize {
		var width = CGFloat(PADDING * 3)
		var height = CGFloat(PADDING * 2.5)
		let frame = UIApplication.shared.keyWindow?.frame
		
		if (title != nil && frame != nil && (arrowPosition == .left || arrowPosition == .right)) {
			let widthDelta = CGFloat(ARROW_SIZE)
			let boundingSize = CGSize(width: frame!.size.width - widthDelta - CGFloat(PADDING * 3), height: CGFloat(FLT_MAX))
			let result = title!.boundingRect(with: boundingSize, options: .usesDeviceMetrics, attributes: nil, context: nil)
			
			width += result.width
			height += result.height
		}
		
		return CGSize(width: width, height: height)
	}
	
	
	// MARK:- Drawing & Animation
	override func draw(_ rect: CGRect) {
//		CGContextRef ctx = UIGraphicsGetCurrentContext();
//		CGContextSaveGState(ctx);
//		
//		CGSize size = [self sizeWithFont:[self font]];
//		
//		CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake([self offsets].width,[self offsets].height, size.width, size.height) cornerRadius:RADIUS].CGPath;
//		CGContextAddPath(ctx, clippath);
//		
//		CGContextSetFillColorWithColor(ctx, self.color.CGColor);
//		
//		CGContextClosePath(ctx);
//		CGContextFillPath(ctx);
//		
//		[self.color set];
//		
//		//  tip of arrow needs to be centered under highlighted region
//		//  this center area is always arrow size divided by 2
//		float center = ARROW_SIZE/2;
//		
//		//  points used to draw arrow
//		//  Wide Arrow --> x = center + - ArrowSize
//		//  Skinny Arrow --> x = center + - center
//		//  Normal Arrow -->
//		CGPoint startPoint = CGPointMake(center - ARROW_SIZE, ARROW_SIZE);
//		CGPoint midPoint = CGPointMake(center, 0);
//		CGPoint endPoint = CGPointMake(center + ARROW_SIZE, ARROW_SIZE);
//		
//		
//		UIBezierPath *path = [UIBezierPath bezierPath];
//		[path moveToPoint:startPoint];
//		[path addLineToPoint:endPoint];
//		[path addLineToPoint:midPoint];
//		[path addLineToPoint:startPoint];
		
		let ctx = UIGraphicsGetCurrentContext()
		
		
		ctx?.saveGState()
		
//		let size = sizeWithFont()
		
	}
	
	func animate() {
		UIView.animate(withDuration: 2.0, delay: 0.3, options: [.repeat, .autoreverse], animations: {
			self.transform = CGAffineTransform(translationX: 0, y: -5)
		}, completion: nil)
	}
}


























