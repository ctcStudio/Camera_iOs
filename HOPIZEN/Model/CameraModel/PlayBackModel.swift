//
//  PlayBackModel.swift
//  CameraDemo
//
//  Created by HungHN on 4/6/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class PlayBackModel: HPZBaseEntity {
    var cameraName:String?
    var cameraID:String?
    var fileName:String?
    
    override func paserStringRespon(message: String) -> Bool {
        if message.contains(find: "\\") {
            let splitData = message.components(separatedBy: "\\")
            if splitData.count >= 2 {
                self.cameraID = splitData[0]
                self.fileName = splitData[1]
                return true
            }
        }
        return false
    }
    
    
    func fillDataToPlayBack(cameraName:String?, cameraId:String?, fileName:String?) -> Void {
        self.cameraName = cameraName
        self.cameraID = cameraId
        self.fileName = fileName
    }
    
    func toString() -> String {
        if(self.cameraName?.isEmpty)! {
            return cameraID! + " - " + fileName!
        }
        return cameraName! + " - " + fileName!
    }
}
