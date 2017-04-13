//
//  HomeTableViewController.swift
//  CameraDemo
//
//  Created by HungHN on 4/4/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var cameraGroupList:[CameraGroup] = []
    var cameraModelList:[CameraModel] = []
    
    var sk:HPZSoketXXXXX?
    var name:String?
    var pass:String?
    var host:String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        self.host = defaults.string(forKey: defaultsKeys.keyServerAddress)
        self.name = defaults.string(forKey: defaultsKeys.keyUserName)
        self.pass = defaults.string(forKey: defaultsKeys.keyPassword)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier:"cameraViewCell")
        self.tableView.allowsMultipleSelection = true
        
        HPZMainFrame.addMenuLeft(title: "Play back", titleColor: UIColor.white, target: self, action: #selector(playBack(sender:)))
        HPZMainFrame.addMenuRight(title: "Realtime", titleColor: UIColor.white, target: self, action: #selector(realTime(sender:)))
        HPZMainFrame.addNaviHomeBtn(target: self, action: #selector(homeAction(_:)))
        self.initSocket()
    }
    
    func homeAction(_ sender: AnyObject) {
        return
    }

    func playBack(sender:UIButton!){
        HPZMainFrame.showPlayBackVC(cameraGroup:cameraGroupList)
    }
    
    func realTime(sender:UIButton!){
       self.sendMessageCheckOnline()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return cameraGroupList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let cameraGroup = self.cameraGroupList[section]
        return cameraGroup.cameraList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cameraGroup = self.cameraGroupList[indexPath.section]
        let cameraModel = cameraGroup.cameraList[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cameraViewCell", for: indexPath) as! HomeTableViewCell
        cell.showCamera(camera: cameraModel)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        let cameraGroup = self.cameraGroupList[section]
        return cameraGroup.groupName!
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let sr = tableView.indexPathsForSelectedRows {
            if sr.count == 4 {
                let alertController = UIAlertController(title: "Oops", message:
                    "You are limited to 4 selections", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                }))
                self.present(alertController, animated: true, completion: nil)
                
                return nil
            }
        }
        
        return indexPath

    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cameraGroup = self.cameraGroupList[indexPath.section]
//        let cameraModel = cameraGroup.cameraList[indexPath.item]
//        var listCamera:[CameraModel] = []
//        listCamera.append(cameraModel)
//        HPZMainFrame.showRealTimeDetailVC(cameraGroup: self.cameraGroupList, cameraModel: listCamera)
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.isSelected {
                cell.accessoryType = .checkmark
            }
        }
        
        if let sr = tableView.indexPathsForSelectedRows {
            print("didDeselectRowAtIndexPath selected rows:\(sr)")
            let cameraGroup = self.cameraGroupList[indexPath.section]
            let cameraModel = cameraGroup.cameraList[indexPath.item]
            if self.cameraModelList.contains(cameraModel) == false {
                self.cameraModelList.append(cameraModel)
            }
        }
    }
 
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        
        if let sr = tableView.indexPathsForSelectedRows {
            print("didDeselectRowAtIndexPath selected rows:\(sr)")
            let cameraGroup = self.cameraGroupList[indexPath.section]
            let cameraModel = cameraGroup.cameraList[indexPath.item]
            let index = self.cameraModelList.index(of: cameraModel)
            self.cameraModelList.remove(at: index!)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.sk?.close()
        self.sk = nil
    }
    
    
    func initSocket() {
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

extension HomeTableViewController : HPZSoketXXXXXDelegate {
    func socketDidConnect() {
        print("socket Connected")
        self.pSendMessage()
        
    }
    func messageReceived(_ message: String!, messageType type: MessageType) {
        //        print("message:\(message)")
        switch type {
        case MessageType.LOGIN:
            SVProgressHUD.dismiss()
            break
        case MessageType.ONLINE:
            SVProgressHUD.dismiss()
            self.fillterCameraOnline(messsage: message)
            break
        default:
            break
        }
    }
    
    
    private func pSendMessage() -> Void {
        let mMessage:NSString = "@haicuong@:"+name!+":"+pass! as NSString
        self.sk?.sendMessage(toServer: mMessage as String!, messageType: MessageType.LOGIN)
    }
    
    
    func sendMessageCheckOnline() -> Void {
        SVProgressHUD.show()
        var message = "@message@checkonline@message@////"
        var idString = ""
        
        for camera in self.cameraModelList {
            idString = idString + camera.cameraID! + "////"
        }
        
        message = message + idString
        self.sk?.sendMessage(toServer: message as String!, messageType: MessageType.ONLINE)
    }
    
    private func fillterCameraOnline(messsage:String) -> Void {
        var listCameOnline:[CameraModel] = []
        if messsage.contains(find: "@message@checkonline@message@")  {
            let splitDataDetail = messsage.components(separatedBy: "////")
            for camera in cameraModelList {
                for value in splitDataDetail {
                    if(camera.cameraID == value) {
                        camera.isOnline = true
                        listCameOnline.append(camera)
                        break
                    }
                }
            }
            if(listCameOnline.count > 0) {
                HPZMainFrame.showRealTimeDetailVC(cameraGroup: cameraGroupList, cameraModel: listCameOnline)
            } else {
                let alertController = UIAlertController(title: "Oops", message:
                    "Camera offline", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            SVProgressHUD.dismiss()
        }
    }
    
}

