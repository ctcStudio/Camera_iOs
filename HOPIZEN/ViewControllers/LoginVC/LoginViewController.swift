//
//  HPZHomeViewController.swift
//  HOPIZEN
//
//  Created by Thuy Do Thanh on 12/13/16.
//  Copyright © 2016 Thuy Do Thanh. All rights reserved.
//

import UIKit
import SwiftSocket
import Foundation

class LoginViewController: UIViewController{

    var sk:HPZSoketXXXXX?
    lazy var isFrist = false
    lazy var hasSavePass = false
    var name:String?
    var pass:String?
    var host:String?
    
    @IBOutlet weak var contentLayout: UIView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var savePassword: UIImageView!
    
    lazy var cameraList:[CameraGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderWidth:CGFloat = 1.0
    
        let myColor : UIColor = UIColor(red: 60, green: 63, blue: 65)
        self.contentLayout.layer.borderColor = myColor.cgColor
        self.contentLayout.layer.borderWidth = borderWidth
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickSavePassword(tapGestureRecognizer:)))
        self.savePassword.isUserInteractionEnabled = true
        self.savePassword.addGestureRecognizer(tapGestureRecognizer)
        
        let defaults = UserDefaults.standard
        self.name = defaults.string(forKey: defaultsKeys.keyUserName)
        self.userName.text = self.name
        self.pass = defaults.string(forKey: defaultsKeys.keyPassword)
        self.password.text = self.pass
        self.host = defaults.string(forKey: defaultsKeys.keyServerAddress)
        if (self.host != nil && !(self.host?.isEmpty)!) {
            self.serverAddress.text = self.host
        }
        
        self.hasSavePass = defaults.bool(forKey: defaultsKeys.keyHasSavePassword)
        if(self.hasSavePass) {
            self.savePassword.image = UIImage(named: "checkbox_normal_white");
        } else {
            self.savePassword.image = UIImage(named: "checkbox_checked_white");
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.sk?.close()
    }

    func clickSavePassword(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let imageClick = tapGestureRecognizer.view as! UIImageView
        if(self.hasSavePass) {
            imageClick.image = UIImage(named: "checkbox_normal_white");
            self.hasSavePass = false;
        } else {
            imageClick.image = UIImage(named: "checkbox_checked_white");
            self.hasSavePass = true;
        }
    }


    @IBAction func login(_ sender: UIButton) {
        self.host = self.serverAddress.text
        self.name = self.userName.text
        self.pass = self.password.text
        if((host?.isEmpty)!
            || (name?.isEmpty)!
            || (pass?.isEmpty)!) {
            NSLog("Login: error input data");
            return
        }
        SVProgressHUD.show()
        self.sk?.close()
        self.sk = nil
        self.sk = HPZSoketXXXXX(host:host , port: 5050);
        self.sk?.delegate = self

    }
}

extension LoginViewController : HPZSoketXXXXXDelegate {
    func socketDidConnect() {
        print("socket Connected")
        self.pSendMessage()
        
    }
    func messageReceived(_ message: String!, messageType type: MessageType) {
//        print("message:\(message)")
        if (message.contains(find: "cameralistbegin")){
            let rangeBegin = message.range(of: "cameralistbegin")?.upperBound
            let rangeEnd = message.range(of: "cameralistend")?.lowerBound
            let range = rangeBegin!..<rangeEnd!
            let contentMessage = message.substring(with: range)
            if contentMessage.contains(find: "////") {
                let modified = contentMessage.replace(target: "\0", withString:"")
                let splitData = modified.components(separatedBy: "\r\n")
                
                for value in splitData {
                    if value.contains(find:"////") == false {
                        continue
                    }
                    let cameraGroup = CameraGroup()
                    if cameraGroup.paserStringRespon(message: value) {
                        self.cameraList.append(cameraGroup)
                    }
                }
                
                if self.cameraList.count > 0 {
                    self.sendMessageCheckOnline()
                    let defaults = UserDefaults.standard
                    if(hasSavePass) {
                        defaults.set(self.name, forKey: defaultsKeys.keyUserName)
                        defaults.set(self.pass, forKey: defaultsKeys.keyPassword)
                        defaults.set(self.host, forKey: defaultsKeys.keyServerAddress)
                    }
                    defaults.set(self.hasSavePass, forKey: defaultsKeys.keyHasSavePassword)
                }
            }
        } else if message.contains(find: "@message@checkonline@message@") {
            self.fillterCameraOnline(messsage: message)
            
        } else if  message.contains(find: "@message@<picture>@message@")
            || message.contains(find: "GPS"){
            print("ThuyDT")
        }
       
    }
    
    
    @objc private func pSendMessage() -> Void {
       
        let mMessage:NSString = "@haicuong@:"+name!+":"+pass! as NSString
        self.sk?.sendMessage(toServer: mMessage as String!, messageType: MessageType.LOGIN)
    }
    
    
    private func sendMessageCheckOnline() -> Void {
        var message = "@message@checkonline@message@"
        var idString = ""
       
        for value in self.cameraList {
            for camera in value.cameraList {
                idString = idString + "////" + camera.cameraID!
            }
        }
        
        message = message + idString
        self.sk?.sendMessage(toServer: message as String!, messageType: MessageType.ONLINE)
    }
    
    private func fillterCameraOnline(messsage:String) -> Void {
        if messsage.contains(find: "////")  {
            let splitDataDetail = messsage.components(separatedBy: "////")
            for cameraGroup in cameraList {
                let listCamera = cameraGroup.cameraList
                for camera in listCamera {
                    for value in splitDataDetail {
                        if(camera.cameraID == value) {
                            camera.isOnline = true
                            break
                        }
                    }
                }
            }
        }
        
        SVProgressHUD.dismiss()
        HPZMainFrame.showHomeVC(cameraGroup:cameraList)
    }
    
}





