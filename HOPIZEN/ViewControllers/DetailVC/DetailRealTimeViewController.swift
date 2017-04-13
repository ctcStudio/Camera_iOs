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
            realTimeView.delegate = self
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

extension DetailRealTimeViewController: RealTimeDelegate {
    
    func showFullMap(camera: CameraModel) {
        
    }
    
    func showOrHideGps(isShow: Bool, camera: CameraModel) {
        let screenSize: CGRect = UIScreen.main.bounds
        var scrollHeight:CGFloat = 0
        for i in 0..<realTimeViewList.count {
            let realTimeView = realTimeViewList[i]
            if(realTimeView.cameraModel?.cameraID == camera.cameraID) {
                let height = screenSize.width + 70 + screenSize.width
                let viewSize:CGRect = CGRect.init(x: 0, y: scrollHeight, width: screenSize.width, height: height)
                realTimeView.frame = viewSize
                scrollHeight = scrollHeight + height
            } else {
                let height = screenSize.width + 70
                let viewSize:CGRect = CGRect.init(x: 0, y: scrollHeight, width: screenSize.width, height: height)
                realTimeView.frame = viewSize
                realTimeView.mapView.isHidden = true
                scrollHeight = scrollHeight + height
            }
        }
        let scrollSize:CGSize = CGSize.init(width: screenSize.width, height: scrollHeight)
        self.scrollView.contentSize = scrollSize
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func updateLoaction(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
    }
}
