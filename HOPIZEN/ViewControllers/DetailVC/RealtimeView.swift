//
//  RealtimeView.swift
//  CameraDemo
//
//  Created by HungHN on 4/7/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class RealtimeView: UIView {

    
    @IBOutlet weak var heightView: NSLayoutConstraint!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func showOrHiddenView() {
        if 1==1 {
            self.heightView.constant = 0
        } else {
            self.heightView.constant = 375
        }
        self.updateConstraints()
    }

}
