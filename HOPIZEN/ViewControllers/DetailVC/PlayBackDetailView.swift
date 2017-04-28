//
//  PlayBackDetailView.swift
//  CameraDemo
//
//  Created by HungHN on 4/7/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

protocol PlayBackDelegate {
    
    func showFullGps(playback:PlayBackModel)
    
    func updateLoaction(latitude:CLLocationDegrees, longitude: CLLocationDegrees)
}

class PlayBackDetailView: UIView, GMSMapViewDelegate {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var ImagePlayBack: UIImageView!
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var cameraInfo: UILabel!
    @IBOutlet weak var addressView: UILabel!
    @IBOutlet weak var cameraSlider:UISlider!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    
    var delegate:PlayBackDelegate!
    var playBack:PlayBackModel?
    var timePlay:Int16 = 0
    var speed: Int8 = 1
    var cameraId:Int64 = 0
    
    var sk:HPZSoketXXXXX?
    var name:String?
    var pass:String?
    var host:String?
    var hasGetAddress:Bool! = false
    var hasChangeTimePlay:Bool! = false
    var hasShowFullMap:Bool! = false

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
        
        self.cameraSlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        self.cameraSlider.addTarget(self, action: #selector(sliderValueTouchDown(_:)), for: .touchDown)
        self.cameraSlider.isContinuous = false
        let imageThumb:UIImage = (UIImage.init(named: "ic_slider_thumb")!.stretchableImage(withLeftCapWidth: 10, topCapHeight: 0))
        self.cameraSlider.setThumbImage(imageThumb, for: UIControlState.normal)
        self.cameraName.text = self.playBack?.cameraName
        self.cameraInfo.text = String(format: " 0 km/h %s %02d:%02d:%02d",(self.playBack?.cameraID)!,12,00,00)
        self.addressView.text = ""
        self.mapView.delegate = self
    }
    
    func clickMapView(tapGestureRecognizer: UITapGestureRecognizer) {
        if(self.delegate != nil) {
            self.delegate.showFullGps(playback: self.playBack!)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if(self.delegate != nil) {
            self.delegate.showFullGps(playback: self.playBack!)
        }
    }
    
    func loadViewFromNib() -> UIView {
        let nibName:String = "PlayBackDetailView"
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func getAddress(latitude:CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation.init(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?.last
                let addressDic = pm?.addressDictionary
                var address:[String] = []
                let subAdministrativeArea = addressDic?["SubAdministrativeArea"] as? String ?? ""
                let name = addressDic?["Name"] as? String ?? ""
                let street = addressDic?["Street"] as? String ?? ""
                let state = addressDic?["State"] as? String ?? ""
                if(subAdministrativeArea.isEmpty == false) {
                    address.append(subAdministrativeArea)
                }
                if(name.isEmpty == false) {
                    address.append(name)
                }
                if(street.isEmpty == false) {
                    address.append(street)
                }
                if(state.isEmpty == false) {
                    address.append(state)
                }
                self.addressView.text = address.joined(separator: ", ")
            }
                
            else {
                print("Problem with the data received from geocoder")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hasGetAddress = false
            }
        })
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
    
    func sethiddenView(isHidden:Bool) {
        if isHidden {
            self.heightView.constant = 0
        } else {
            self.heightView.constant = self.frame.size.width
        }
        self.updateConstraints()
    }
    
    @IBAction func clickGps(_ sender: UIButton) {
        if self.mapView.isHidden {
            self.mapView.isHidden = false
            self.sethiddenView(isHidden: false)
        } else {
            self.mapView.isHidden = true
            self.sethiddenView(isHidden: true)
        }
    }
    
    func sliderValueTouchDown(_ sender:UISlider!) {
        print("Slider sliderValueTouchDown")
        self.hasChangeTimePlay = true
    }
    
    func sliderValueDidChange(_ sender:UISlider!) {
        // Use this code below only if you want UISlider to snap to values step by step
        let roundedStepValue = round(sender.value / 1.0) * 1.0
        sender.value = roundedStepValue
        
        print("Slider step value \(Int(roundedStepValue))")
        SVProgressHUD.show()
        self.sendStopVodData()
        self.timePlay = Int16(roundedStepValue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // your code here
            self.sendGetVodData()
            self.hasChangeTimePlay = false
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
    
    func sendStopVodData() {
        var data:Data = Data()
        let msg = "@message@yeucauVOD@message@"
        data.append(msg.data(using: String.Encoding.ascii)!)
        let dataCameraId:Data = Data(from:self.cameraId)
        data.append(dataCameraId)
        data.append((self.playBack?.fileName?.data(using: String.Encoding.ascii)!)!)
        data.append(Data.init(from: Int16(3601)))
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
            var speed:String! = "0 km/h"
            if (gpsTrim.isEmpty == false) {
                let gpsInfo:GpsInfoModel! = GpsInfoModel()
                let isParse = gpsInfo?.paserStringRespon(message: gpsTrim)
                if isParse! {
                    if(self.delegate != nil && self.hasShowFullMap) {
                        self.delegate.updateLoaction(latitude: (gpsInfo?.lat)!, longitude: (gpsInfo.log)!)
                    }
                    if(self.mapView.isHidden == false) {
                        self.loadCameraPosition(latitude: (gpsInfo?.lat)!, longitude: (gpsInfo?.log)!)
                    }
                    speed  = String(format: "%.2f", gpsInfo.getSpeedKM()) +  " km/h"
                    
                    if(self.hasGetAddress == false) {
                        self.getAddress(latitude: (gpsInfo?.lat)!, longitude: (gpsInfo?.log)!)
                        self.hasGetAddress = true
                    }
                }
            }
            
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
                if(self.hasChangeTimePlay == false) {
                    self.cameraSlider.value = Float.init(count)
                }
                let hour = count/60
                let minus = count%60
                let infoCam = fileName + String(format: ":%02d:%02d",hour,minus)
                let info:String! = infoCam + " " + speed
                self.cameraInfo.text = info
            }
            
        }
        
    }
}

