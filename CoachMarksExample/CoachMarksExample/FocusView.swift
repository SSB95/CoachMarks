//
//  CircleView.swift
//  CoachMarksExample
//
//  Created by Tulio Troncoso on 6/15/17.
//  Copyright © 2017 Darin Doria. All rights reserved.
//

import Foundation
import UIKit

class FocusView: UIView {
    enum FocusSwipeDirection {
        case leftToRight
        case rightToLeft
    }
    
    var animationShouldStop: Bool = false
    var swipeDirection: FocusSwipeDirection = .leftToRight
    
    func swipeIn(frame: CGRect) {
        
    }
}
