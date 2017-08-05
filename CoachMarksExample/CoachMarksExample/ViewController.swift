//
//  ViewController.swift
//  CoachMarksExample
//
//  Created by Darin Doria on 6/13/17.
//  Copyright © 2017 Darin Doria. All rights reserved.
//

import UIKit
import CoachMarks

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let coachMarks = [
            [
                "rect": CGRect(x: 6, y: 24, width: 40, height: 40),
                "caption": "Synchronize your mail",
                "shape": "circle",
                "font": UIFont.boldSystemFont(ofSize: 14.0)
            ],
            [
                "rect": CGRect(x: 275, y: 24, width: 40, height: 40),
                "caption": "Create a new message",
                "shape": "circle"
            ],
            [
                "rect": CGRect(x: 0, y: 125, width: 320, height: 60),
                "caption": "Swipe for more options",
                "shape": "square",
                "swipe": true
            ]
        ]
        
        // let coachMarksView = CoachMarksView(with: self.view.bounds, coachMarks: coachMarks)
        let coachMarksView = CoachMarksView(frame: self.view.bounds, coachMarks: coachMarks)
      
        self.view.addSubview(coachMarksView)
        coachMarksView.start()
    }
}

