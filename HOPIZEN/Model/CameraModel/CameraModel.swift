//
//  CameraModel.swift
//  CameraDemo
//
//  Created by Thuy Do Thanh on 12/27/16.
//  Copyright © 2016 Thuy Do Thanh. All rights reserved.
//

import UIKit

class CameraModel: HPZBaseEntity {
    var cameraGroup:String?
    var cameraName:String?
    var cameraID:String?
    var isOnline:Bool?
    
    
    override func paserStringRespon(message: String) -> Bool {
        print("respon:\(message)")
        let splitData = message.components(separatedBy: "////")
        if splitData.count == 2 {
            self.cameraName = splitData[0]
            self.cameraID = splitData[1]
            return true
        }
        return false
    }
    
    
    func fillDataToCamera(iname1:String, iname2:String, icameraId:String) -> Void {
        self.cameraGroup = iname1
        self.cameraName = iname2
        self.cameraID = icameraId
    }
    
    func toString() -> String {
        return cameraGroup! + " - " + cameraName!
    }

}
