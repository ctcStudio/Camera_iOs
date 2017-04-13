//
//  PlayBackViewController.swift
//  CameraDemo
//
//  Created by HungHN on 4/5/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class PlayBackViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate ,UIPickerViewDataSource {
    let pickerCamera:Int = 1;
    let pickerSpeed:Int = 2;
    let cellIdentifier = "playBackCell";

    
    @IBOutlet weak var layoutContent: UIView!
    @IBOutlet weak var selectFromDate: UIButton!
    @IBOutlet weak var selectToDate: UIButton!
    @IBOutlet weak var selectCamera: UIButton!
    @IBOutlet weak var selectSpeed: UIButton!
    @IBOutlet weak var layoutChooseDate: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var speedPicker: UIPickerView!
    @IBOutlet weak var cameraPicker: UIPickerView!
    @IBOutlet weak var playBackView: UITableView!
    
    var host:String?
    var name:String?
    var pass:String?
    var skPlayer:HPZSoketXXXXX?
    
    var speedString:[String] = ["x1","x2","x3","x4","x5","x6","x7","x8","x9"]
    var speed:[Int8] = [1,2,3,4,5,6,7,8,9]
    
    var selectedCamera : CameraModel?
    var selectedSpeed: Int8?
    var selectedSpeedString: String?
    
    var cameraGroupList:[CameraGroup] = []
    var cameraList:[CameraModel] = []
    var playBackList:[PlayBackModel] = []
    var selectType:PickerType =  PickerType.FromType
    var fromDate:Date?
    var toDate:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        self.host = defaults.string(forKey: defaultsKeys.keyServerAddress)
        self.name = defaults.string(forKey: defaultsKeys.keyUserName)
        self.pass = defaults.string(forKey: defaultsKeys.keyPassword)

        if (self.host?.isEmpty)! {
            self.host = "haicuong.no-ip.biz"
        }
        
        self.intCameraList()
        self.initSocket()
        
        // Do any additional setup after loading the view.
        let nowDate = Date()
        self.fromDate = nowDate.startOfDay
        self.toDate = nowDate.endOfDay!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.selectFromDate.setTitle(dateFormatter.string(from:self.fromDate!), for: UIControlState.normal)
        self.selectToDate.setTitle(dateFormatter.string(from:self.toDate!), for: UIControlState.normal)
        
        self.speedPicker.tag = pickerSpeed
        self.speedPicker.dataSource = self
        self.speedPicker.delegate = self
        self.cameraPicker.tag = pickerCamera
        self.cameraPicker.dataSource = self
        self.cameraPicker.delegate = self
        
        self.playBackView.dataSource = self
        self.playBackView.delegate = self
        
       self.playBackView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        if(self.cameraList.count > 0) {
            self.selectedCamera = self.cameraList[0]
            self.selectCamera.setTitle(selectedCamera?.toString(), for: UIControlState.normal)
        }
        self.selectedSpeedString = self.speedString[0]
        self.selectedSpeed = self.speed[0]
        self.selectSpeed.setTitle(selectedSpeedString, for: UIControlState.normal)
        
        HPZMainFrame.addBackBtn(target: self, action: #selector(clickBack(_:)))
        HPZMainFrame.addNaviHomeBtn(target: self, action: #selector(homeAction(_:)))
    }
    
    func homeAction(_ sender: AnyObject) {
        HPZMainFrame.showHomeVC(cameraGroup:cameraGroupList)
    }

    
    func clickBack(_ sender:UIButton!){
        HPZMainFrame.showHomeVC(cameraGroup:cameraGroupList)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.skPlayer?.close()
        self.skPlayer = nil
    }
    
    func intCameraList() -> Void {
        self.cameraList.removeAll()
        for cameraGroup in self.cameraGroupList {
            for camera in cameraGroup.cameraList {
                self.cameraList.append(camera)
            }
        }
    }

    
    func initSocket() -> Void {
        self.skPlayer?.close()
        self.skPlayer = nil
        self.skPlayer = HPZSoketXXXXX(host:host , port: 5051);
        self.skPlayer?.delegate = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.skPlayer?.close()
        self.skPlayer = nil
    }
    
    @IBAction func selected(_ sender: UIButton) {
        switch self.selectType {
        case PickerType.FromType:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            self.selectFromDate.setTitle(dateFormatter.string(from:self.datePicker.date), for: UIControlState.normal)
            break
        case PickerType.ToType:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            self.selectToDate.setTitle(dateFormatter.string(from:self.datePicker.date), for: UIControlState.normal)
            break
        case PickerType.NameType:
            self.selectCamera.setTitle(selectedCamera?.toString(), for: UIControlState.normal)
            break
        case PickerType.SpeedType:
            self.selectSpeed.setTitle(selectedSpeedString, for: UIControlState.normal)
            break
        }
        self.layoutChooseDate.isHidden = true
    }
    
    @IBAction func getData(_ sender: UIButton) {
        self.pSendMessageGetData()
    }
    
    @IBAction func chooseFromDate(_ sender: UIButton) {
        self.selectType = PickerType.FromType
        self.layoutChooseDate.isHidden = false
        self.datePicker.isHidden = false
        self.speedPicker.isHidden = true
        self.cameraPicker.isHidden = true

    }
    
    @IBAction func chooseToDate(_ sender: UIButton) {
        self.selectType = PickerType.ToType
        self.layoutChooseDate.isHidden = false
        self.datePicker.isHidden = false
        self.speedPicker.isHidden = true
        self.cameraPicker.isHidden = true    }
    
    @IBAction func chooseCamera(_ sender: UIButton) {
        self.selectType = PickerType.NameType
        self.layoutChooseDate.isHidden = false
        self.datePicker.isHidden = true
        self.speedPicker.isHidden = true
        self.cameraPicker.isHidden = false
    }
    
    @IBAction func chooseSpeed(_ sender: UIButton) {
        self.selectType = PickerType.SpeedType
        self.layoutChooseDate.isHidden = false
        self.datePicker.isHidden = true
        self.speedPicker.isHidden = false
        self.cameraPicker.isHidden = true
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playBackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell!
        let playBack = playBackList[indexPath.row]
        cell?.textLabel?.text = playBack.toString()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playBack = self.playBackList[indexPath.row]
        let camId = Int64(playBack.cameraID!)
        HPZMainFrame.showPlayBackDetailVC( cameraGroup: self.cameraGroupList, playBackList: self.playBackList, playBack: playBack, camId: camId!, speed: self.selectedSpeed!)
    }
    // MARK: - Picker view data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == pickerCamera) {
            return self.cameraList[row].toString()
        } else if (pickerView.tag == pickerSpeed) {
            return self.speedString[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == pickerCamera) {
            self.selectedCamera = self.cameraList[row]
        } else if (pickerView.tag == pickerSpeed) {
            self.selectedSpeed = self.speed[row]
            self.selectedSpeedString = self.speedString[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == pickerCamera) {
            return self.cameraList.count
        } else if (pickerView.tag == pickerSpeed) {
            return self.speedString.count
        }
        return 0
    }
}

extension PlayBackViewController : HPZSoketXXXXXDelegate {
    func socketDidConnect() {
        print("socket Connected")
        self.pSendMessageLogin()
    }
    
    func messageReceived(_ message: String!, messageType type: MessageType) {
        switch type {
        case MessageType.LOGIN_GETDATA:
            SVProgressHUD.dismiss()
            break
        case MessageType.GETDATA:
            SVProgressHUD.dismiss()
            playBackList.removeAll()
            let data = message.replace(target: "@message@timkiemxemlai@message@", withString: "")
            
            if data.contains(find: "@begin@") {
                let modified = data.replace(target: "\0", withString:"")
                let splitData = modified.components(separatedBy: "@begin@")
                for storeData in splitData {
                    if(storeData.isEmpty) {
                        continue
                    }
                    let playback = PlayBackModel()
                    if playback.paserStringRespon(message: storeData) {
                        playback.cameraName = self.selectedCamera?.cameraName
                        self.playBackList.append(playback)
                    }
                }
            }
            self.playBackView.reloadData()
            break
        default:
            break
        }
    }
    @objc private func pSendMessageLogin() -> Void {
        SVProgressHUD.show()
        let mMessage:NSString = "@haicuong@:"+name!+":"+pass! as NSString
        self.skPlayer?.sendMessage(toServer: mMessage as String!, messageType: MessageType.LOGIN_GETDATA)
    }
    
    @objc func pSendMessageGetData() -> Void {
        SVProgressHUD.show()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var mMessage:String = "@message@timkiemxemlai@message@@begin@" + name!+"////"+pass! + "////"
        mMessage = mMessage + (self.selectedCamera?.cameraID!)! + "////" + dateFormatter.string(from:self.fromDate!) + "////" + dateFormatter.string(from:self.toDate!)
        
        self.skPlayer?.sendMessage(toServer: mMessage as String!, messageType: MessageType.GETDATA)
    }

}
