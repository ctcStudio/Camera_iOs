//
//  DetailViewController.swift
//  CameraDemo
//
//  Created by HungHN on 4/5/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,GMSMapViewDelegate {
    var cameraGroupList:[CameraGroup] = []
    var playBackList:[PlayBackModel] = []
    
    var playBackView:PlayBackDetailView?
    var playBack:PlayBackModel?
    var cameraId:Int64 = 0
    var speed:Int8 = 1
    var timePlay:Int16 = 0
    
    var sk:HPZSoketXXXXX?
    var name:String?
    var pass:String?
    var host:String?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let screenSize: CGRect = UIScreen.main.bounds
        let height = screenSize.width + 30 + 70 + screenSize.width
        let viewSize:CGRect = CGRect.init(x: 0, y: 0, width: screenSize.width, height: height)
        
        self.playBackView = PlayBackDetailView.init(frame: viewSize)
        self.playBackView?.playBack = self.playBack!
        self.playBackView?.cameraId = self.cameraId
        self.playBackView?.speed = self.speed
        self.playBackView?.isHidden = false
        self.playBackView?.delegate = self
        
        self.scrollView.contentSize = (self.playBackView?.bounds.size)!
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.addSubview(self.playBackView!)
        
        self.playBackView?.initSocket()
        self.mapView.delegate = self
        HPZMainFrame.addBackBtn(target: self, action: #selector(playBack(sender:)))
        
        HPZMainFrame.addNaviHomeBtn(target: self, action: #selector(homeAction(_:)))
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.mapView.isHidden = true
        self.playBackView?.hasShowFullMap = false
    }
    
    func homeAction(_ sender: AnyObject) {
        HPZMainFrame.showHomeVC(cameraGroup:cameraGroupList)
    }
    
    func clickBack(_ sender:UIButton!){
        if(self.mapView.isHidden) {
            HPZMainFrame.showPlayBackVC(cameraGroup: self.cameraGroupList, playBackList: self.playBackList)
        } else {
            self.mapView.isHidden = true
            self.playBackView?.hasShowFullMap = false
        }
    }
    
    func playBack(sender:UIButton!){
        self.sk?.close()
        self.sk = nil
        
        HPZMainFrame.showPlayBackVC(cameraGroup:cameraGroupList, playBackList: playBackList)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.sk?.close()
        self.sk = nil
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.playBackView?.closeSocket()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension DetailViewController:PlayBackDelegate {
    func showFullGps(playback: PlayBackModel) {
        self.mapView.isHidden = false
        self.playBackView?.hasShowFullMap = true
    }
    
    
    func updateLoaction(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        loadCameraPosition(latitude: latitude, longitude:  longitude)
    }
    
    func loadCameraPosition(latitude:CLLocationDegrees, longitude: CLLocationDegrees) {
        self.mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        self.mapView.camera = camera
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = self.playBack?.cameraName
        marker.snippet = self.playBack?.cameraID
        marker.map = mapView
    }
}
