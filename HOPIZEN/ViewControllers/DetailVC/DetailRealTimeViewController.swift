//
//  DetailRealTimeViewViewController.swift
//  CameraDemo
//
//  Created by HungHN on 4/12/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class DetailRealTimeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var cameraGroupList:[CameraGroup] = []
    
    var cameraModel:CameraModel?
    var realTimeView:RealTimeDetailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        HPZMainFrame.addMenuLeft(title: "Back", titleColor: UIColor.white, target: self, action: #selector(clickBack(sender:)))
        
        let screenSize: CGRect = UIScreen.main.bounds
        let height = screenSize.width + 70 + screenSize.width
        let viewSize:CGRect = CGRect.init(x: 0, y: 0, width: screenSize.width, height: height)
        
        self.realTimeView = RealTimeDetailView.init(frame: viewSize)
        self.realTimeView.cameraModel = self.cameraModel
        self.realTimeView?.isHidden = false
        
        self.scrollView.contentSize = (self.realTimeView?.bounds.size)!
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.addSubview(self.realTimeView!)
        
        self.realTimeView?.initSocket()
    }
    
    func clickBack(sender:UIButton!){
        HPZMainFrame.showHomeVC(cameraGroup:cameraGroupList)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.realTimeView?.closeSocket()
        SVProgressHUD.dismiss()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.realTimeView?.closeSocket()
    }

}
