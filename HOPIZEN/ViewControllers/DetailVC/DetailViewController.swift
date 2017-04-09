//
//  DetailViewController.swift
//  CameraDemo
//
//  Created by HungHN on 4/5/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var cameraGroupList:[CameraGroup] = []
    var playBackList:[PlayBackModel] = []

    var playBackView:PlayBackDetailView?
    var playBack:PlayBackModel?
    var cameraId:Int64 = 0
    var speed:Int8 = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
        playBackView = PlayBackDetailView(frame:screenSize)
        self.playBackView?.playBack = self.playBack!
        self.playBackView?.cameraId = self.cameraId
        self.playBackView?.speed = self.speed
        self.view.addSubview(self.playBackView!)
        self.playBackView?.initSocket()
        // Do any additional setup after loading the view.
        HPZMainFrame.addMenuLeft(title: "Play back", titleColor: UIColor.white, target: self, action: #selector(playBack(sender:)))
    }
    
    func playBack(sender:UIButton!){
        HPZMainFrame.showPlayBackVC(cameraGroup:cameraGroupList, playBackList: playBackList)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
