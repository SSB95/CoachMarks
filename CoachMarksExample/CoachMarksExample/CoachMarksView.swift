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

protocol CoachMarksViewDelegate {
    func coachMarksView(_ coachMarksView: CoachMarksView, willNavigateTo index: Int)
    func coachMarksView(_ coachMarksView: CoachMarksView, didNavigateTo index: Int)
    func coachMarksViewWillCleanup(_ coachMarksView: CoachMarksView)
    func coachMarksViewDidCleanup(_ coachMarksView: CoachMarksView)
    func didTap(at index: Int)
}

class CoachMarksView: UIView {
    
}
