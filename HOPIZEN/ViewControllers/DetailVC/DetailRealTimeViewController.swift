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
    
    var cameraModelList:[CameraModel] = []
    var realTimeViewList:[RealTimeDetailView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        let screenSize: CGRect = UIScreen.main.bounds
        var scrollHeight:CGFloat = 0
        for i in 0..<self.cameraModelList.count {
            let height = screenSize.width + 70
            let viewSize:CGRect = CGRect.init(x: 0, y: scrollHeight, width: screenSize.width, height: height)
            let cameraModel = self.cameraModelList[i]
            let realTimeView = RealTimeDetailView.init(frame: viewSize)
            realTimeView.cameraModel = cameraModel
            realTimeView.isHidden = false
            self.realTimeViewList.append(realTimeView)
            self.scrollView.addSubview(realTimeView)
            scrollHeight = scrollHeight + height
        }
        
        let scrollSize:CGSize = CGSize.init(width: screenSize.width, height: scrollHeight)
        self.scrollView.contentSize = scrollSize
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.initAllSocket()
        
        HPZMainFrame.addBackBtn(target: self, action: #selector(clickBack(_:)))
        HPZMainFrame.addNaviHomeBtn(target: self, action: #selector(homeAction(_:)))
    }
    
    func homeAction(_ sender: AnyObject) {
        HPZMainFrame.showHomeVC(cameraGroup:cameraGroupList)
    }
    
    func clickBack(_ sender:UIButton!){
        HPZMainFrame.showHomeVC(cameraGroup:cameraGroupList)
    }
    
    func initAllSocket() {
        for realTimeView in self.realTimeViewList {
            realTimeView.initSocket()
        }
    }
    
    func closeAllSocker() {
        for realTimeView in self.realTimeViewList {
            realTimeView.closeSocket()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        SVProgressHUD.dismiss()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.closeAllSocker()
    }
    
}
