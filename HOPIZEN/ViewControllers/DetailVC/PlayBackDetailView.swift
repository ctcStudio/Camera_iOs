//
//  PlayBackDetailView.swift
//  CameraDemo
//
//  Created by HungHN on 4/7/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class PlayBackDetailView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var ImagePlayBack: UIImageView!
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var cameraInfo: UILabel!
    @IBOutlet weak var addressView: UILabel!
    @IBOutlet weak var cameraSlider:UISlider!
    
    @IBOutlet weak var heightView: NSLayoutConstraint!
    
    var playBack:PlayBackModel?
    var timePlay:Int = 0
    var speed: Int8 = 1
    var cameraId:Int64 = 0
    
    var sk:HPZSoketXXXXX?
    var name:String?
    var pass:String?
    var host:String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
    }
    
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nibName:String = "PlayBackDetailView"
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func showOrHiddenView(isHidden:Bool) {
        if isHidden {
            self.heightView.constant = 0
        } else {
            self.heightView.constant = 375
        }
        self.updateConstraints()
    }
    
    @IBAction func clickGps(_ sender: UIButton) {
    }
}
