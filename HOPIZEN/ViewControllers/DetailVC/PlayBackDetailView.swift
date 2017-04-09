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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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

extension PlayBackDetailView:HPZSoketXXXXXDelegate {
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
        var bytes:[UInt8] = []
        bytes = Array(result!)
        
        var beginPic:Int = 0
        var endPic:Int = 0
        for i in 0..<(bytes.count - 1) {
            if(bytes[i] == 0xFF
                && bytes[i+1] == 0xD8) {
                beginPic = i
            }
            
            if(bytes[i] == 0xFF
                && bytes[i+1] == 0xD9) {
                endPic = i
                break
            }
        }
        
        if (endPic - beginPic) >= 100 {
            let gpsData = result?.subdata(in: 0..<beginPic)
            let gps:String = String.init(data: gpsData!, encoding: String.Encoding.utf8)!
            print(gps)
            
            let pictureData = result?.subdata(in: beginPic..<(endPic+1))
            
            if(endPic + 8 < bytes.count) {
                let cameraIdData = result?.subdata(in: (endPic+1)..<(endPic+9))
                let cameraIdBytes:[UInt8] = Array(cameraIdData!)
                let int64 = UnsafePointer(cameraIdBytes).withMemoryRebound(to: UInt64.self, capacity: 1) {
                    $0.pointee
                }
                print(int64)
            }
            let startFileName = endPic + 9
            let endFileName = startFileName + 13
            if(endFileName < bytes.count) {
                let fileNameData = result?.subdata(in: startFileName..<endFileName)
                let fileName = String.init(data: fileNameData!, encoding: String.Encoding.utf8)!
                print(fileName)

            }
            
            if(endFileName + 2 <= bytes.count) {
                var countByte:[UInt8] = []
                countByte.append(bytes[endFileName])
                countByte.append(bytes[endFileName+1])
                let count = UnsafePointer(countByte).withMemoryRebound(to: UInt16.self, capacity: 1) {
                    $0.pointee
                }
                print(count)
            }
            
        }
        
    }
}
