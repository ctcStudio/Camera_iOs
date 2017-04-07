//
//  PlayBackDetailView.swift
//  CameraDemo
//
//  Created by HungHN on 4/7/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class PlayBackDetailView: UIView {
    
    @IBOutlet weak var ImagePlayBack: UIImageView!
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var cameraInfo: UILabel!
    @IBOutlet weak var addressView: UILabel!
    @IBOutlet weak var cameraSlider:UISlider!

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
    
    @IBAction func clickGps(_ sender: UIButton) {
    }

}
