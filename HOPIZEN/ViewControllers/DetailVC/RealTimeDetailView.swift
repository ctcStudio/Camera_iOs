//
//  PlayBackDetailView.swift
//  CameraDemo
//
//  Created by HungHN on 4/7/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

protocol RealTimeDelegate {
    
    func showOrHideGps(isShow:Bool, camera:CameraModel)
    
    func showFullMap(camera:CameraModel)
    
    func updateLoaction(latitude:CLLocationDegrees, longitude: CLLocationDegrees)
}

class RealTimeDetailView: UIView, GMSMapViewDelegate {
    
    var view: UIView!
    @IBOutlet weak var ImagePlayBack: UIImageView!
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var cameraInfo: UILabel!
    @IBOutlet weak var addressView: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    
    var cameraModel:CameraModel?
    
    var delegate:RealTimeDelegate!
    var hasShowFullMap:Bool! = false
    
    var sk:HPZSoketXXXXX?
    var name:String?
    var pass:String?
    var host:String?
    var hasGetAddress:Bool! = false
    
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
        self.mapView.delegate = self
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nibName:String = "RealTimeDetailView"
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if(self.delegate != nil) {
            self.delegate.showFullMap(camera: self.cameraModel!)
        }
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
        marker.title = self.cameraModel?.cameraName
        marker.snippet = self.cameraModel?.cameraID
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
        if(self.delegate != nil) {
            self.delegate.showOrHideGps(isShow: self.mapView.isHidden, camera: cameraModel!)
        }
        if self.mapView.isHidden {
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
        self.sk?.close()
        self.sk = nil
        self.sk = HPZSoketXXXXX(host:host , port: 5050);
        self.sk?.delegate = self
        
    }
}

extension RealTimeDetailView:HPZSoketXXXXXDelegate {
    func socketDidConnect() {
        self.sendLoginReadTime()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // your code here
            self.sendRealTime()
        }
    }
    
    func sendLoginReadTime() {
        let mMessage:NSString = "@haicuongplayer@:"+name!+":"+pass! as NSString
        self.sk?.sendMessage(toServer: mMessage as String!, messageType: MessageType.LOGIN_REALTIME)
    }
    
    func sendRealTime() {
        let msg = "@message@yeucaulive@message@////" + (self.cameraModel?.cameraID)! + "////"
        self.sk?.sendMessage(toServer: msg, messageType: MessageType.REALTIME)
    }
    
    func messageReceived(_ message: String!, messageType type: MessageType) {
        switch type {
        case MessageType.LOGIN_REALTIME:
            if (message.contains(find: "@message@yeucaulai@message@")){
                self.sendRealTime()
            }
            break
        default:
            break
        }
    }
    
    func messageReceivedData(_ result: Data!, messageType type: MessageType) {
        switch type {
        case MessageType.REALTIME:
            self.parseRealTime(result: result)
        default:
            break
        }
    }
    
    func parseRealTime(result:Data?) {
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
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let info = dateFormatter.string(from:Date()) + " " + speed
                    self.cameraInfo.text = info
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
                let nameCamera:String = (self.cameraModel?.toString())!
                self.cameraName.text = nameCamera
            }
        }
        
    }
}

