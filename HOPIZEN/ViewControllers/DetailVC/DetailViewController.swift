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
    var timePlay:Int16 = 0
    
    var sk:HPZSoketXXXXX?
    var name:String?
    var pass:String?
    var host:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
//        let bundle = Bundle.init(for: PlayBackDetailView.self)
//        let nib = bundle.loadNibNamed("PlayBackDetailView", owner: self, options: nil)
//        self.playBackView = nib?.first as? PlayBackDetailView
//        self.playBackView?.frame = screenSize
        
        self.playBackView = PlayBackDetailView.init(frame: screenSize)
        self.playBackView?.playBack = self.playBack!
        self.playBackView?.cameraId = self.cameraId
        self.playBackView?.speed = self.speed
        self.view.addSubview(self.playBackView!)

        self.playBackView?.isHidden = false
        // Do any additional setup after loading the view.
        HPZMainFrame.addMenuLeft(title: "Play back", titleColor: UIColor.white, target: self, action: #selector(playBack(sender:)))
        
        self.initSocket()
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func initSocket() -> Void {
        let userDefault = UserDefaults.standard
        self.host = userDefault.string(forKey: defaultsKeys.keyServerAddress)
        self.name = userDefault.string(forKey: defaultsKeys.keyUserName)
        self.pass = userDefault.string(forKey: defaultsKeys.keyPassword)
        if((host?.isEmpty)!
            || (name?.isEmpty)!
            || (pass?.isEmpty)!) {
            NSLog("Login: error input data");
            return
        }
        SVProgressHUD.show()
        self.sk?.close()
        self.sk = nil
        self.sk = HPZSoketXXXXX(host:host , port: 5051);
        self.sk?.delegate = self
        
    }
}

extension DetailViewController:HPZSoketXXXXXDelegate {
    func socketDidConnect() {
        self.sendLoginPlayBack()
    }
    
    func sendLoginPlayBack() {
        SVProgressHUD.show()
        let mMessage:NSString = "@haicuong@:"+name!+":"+pass! as NSString
        self.sk?.sendMessage(toServer: mMessage as String!, messageType: MessageType.LOGIN_GETDATA)
    }
    
    func sendGetVodData() {
        var data:Data = Data()
        let msg = "@message@yeucauVOD@message@"
        data.append(msg.data(using: String.Encoding.ascii)!)
        let dataCameraId:Data = Data(from:self.cameraId)
        data.append(dataCameraId)
        data.append((self.playBack?.fileName?.data(using: String.Encoding.ascii)!)!)
        data.append(Data.init(from: self.timePlay))
        data.append(Data.init(from: self.speed))
        self.sk?.sendData(toServer: data, messageType: MessageType.VODDATA)
    }
    
    func messageReceived(_ message: String!, messageType type: MessageType) {
        switch type {
        case MessageType.LOGIN_GETDATA:
            if (message.contains(find: "@message@yeucaulai@message@")){
                sendGetVodData()
            }
            break
        default:
            break
        }
    }
    
    func messageReceivedData(_ result: Data!, messageType type: MessageType) {
        switch type {
        case MessageType.VODDATA:
            SVProgressHUD.dismiss()
            self.parseVodData(result: result)
        default:
            break
        }
    }
    
    func parseVodData(result:Data?) {
        var bytes:[UInt8] = (result?.toArray(type: UInt8.self))!
        var beginPic:Int = -1
        var endPic:Int = -1
        if(bytes.count <= 0) {
            return
        }
        for i in 0..<(bytes.count - 1) {
            if(bytes[i] == 0xFF
                && bytes[i+1] == 0xD8) {
                beginPic = i
            }
            
            if(bytes[i] == 0xFF
                && bytes[i+1] == 0xD9) {
                endPic = i + 1
                break
            }
        }
        
        print("begin: " + String.init(beginPic) + "--end: " + String.init(endPic) + "--- count: " + String.init(bytes.count))
        if(beginPic * endPic < 0) {
            return
        }
        
        if (endPic - beginPic) >= 100 {
            let gpsData = result?.subdata(in: 0..<beginPic)
            let gps:String = String.init(data: gpsData!, encoding: String.Encoding.ascii)!
            let gpsTrim = gps.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            print(gpsTrim)
            
            let pictureData = result?.subdata(in: beginPic..<endPic + 1)
            
            if(endPic + 9 < bytes.count) {
                let cameraIdData = result?.subdata(in: (endPic + 1)..<(endPic + 9))
                let int64:Int64! = cameraIdData?.to(type: Int64.self)
                print(int64)
            }
            let startFileName = endPic + 9
            let endFileName = startFileName + 13
            if(endFileName < bytes.count) {
                let fileNameData = result?.subdata(in: startFileName..<endFileName)
                let fileName = String.init(data: fileNameData!, encoding: String.Encoding.ascii)!
                print(fileName)
            }
            
            if(endFileName + 2 <= bytes.count) {
                let timePlay = result?.subdata(in: endFileName..<(endFileName + 2))
                let count:Int16! = timePlay?.to(type: Int16.self)
                print(count)
            }
            
        }
        
    }
}
