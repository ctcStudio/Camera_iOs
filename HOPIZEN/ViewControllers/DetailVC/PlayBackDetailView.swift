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
    @IBOutlet weak var mapView:UIView!
    
    @IBOutlet weak var heightView: NSLayoutConstraint!
    
    var playBack:PlayBackModel?
    var timePlay:Int16 = 0
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
    
    func sethiddenView(isHidden:Bool) {
        if isHidden {
            self.heightView.constant = 0
        } else {
            self.heightView.constant = self.frame.size.width
        }
        self.updateConstraints()
    }
    
    @IBAction func clickGps(_ sender: UIButton) {
        if(mapView.isHidden) {
            self.mapView.isHidden = false
            self.sethiddenView(isHidden: false)
        } else {
            self.mapView.isHidden = true
            self.sethiddenView(isHidden: true)
        }
    }
    
    func closeSocket() {
        self.sk?.close()
        self.sk = nil
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
            
            let image = UIImage.init(data: pictureData!)
            self.ImagePlayBack.image = image!
            
            if(endPic + 9 < bytes.count) {
                let cameraIdData = result?.subdata(in: (endPic + 1)..<(endPic + 9))
                let int64:Int64! = cameraIdData?.to(type: Int64.self)
                print(int64)
                let nameCamera:String = (self.playBack?.toString())!
                self.cameraName.text = nameCamera
            }
            let startFileName = endPic + 9
            let endFileName = startFileName + 13
            var fileName:String!
            if(endFileName < bytes.count) {
                let fileNameData = result?.subdata(in: startFileName..<endFileName)
                fileName = String.init(data: fileNameData!, encoding: String.Encoding.ascii)!
                print(fileName)
            }
            
            if(endFileName + 2 <= bytes.count) {
                let timePlay = result?.subdata(in: endFileName..<(endFileName + 2))
                let count:Int16! = timePlay?.to(type: Int16.self)
                print(count)
                self.cameraSlider.value = Float.init(count)
                let hour = count/60
                let minus = count%60
                
                let info:String! = fileName + ":" + String.init(hour) + ":" + String.init(minus)
                self.cameraInfo.text = info
            }
            
        }
        
    }
}

