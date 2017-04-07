//
//  CameraGroup.swift
//  CameraDemo
//
//  Created by HungHN on 4/5/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class CameraGroup: HPZBaseEntity {
    var groupName:String?
    var cameraList:[CameraModel] = []
    
    override func paserStringRespon(message: String) -> Bool{
        if message.contains(find: "////") {
            let modified = message.replace(target: "\0", withString:"")
            let splitData = modified.components(separatedBy: "\r\n")
            
            for value in splitData {
                if value.contains(find: "////")  {
                    let splitDataDetail = value.components(separatedBy: "////")
                    if(splitDataDetail.count > 0) {
                        self.groupName = splitDataDetail[0]
                        for i in stride(from:1, to:splitDataDetail.count, by:2) {
                            let camera = CameraModel()
                            camera.cameraGroup = splitDataDetail[0]
                            camera.cameraName = splitDataDetail[i];
                            camera.cameraID = splitDataDetail[i+1];
                            self.cameraList.append(camera)
                        }
                    }
                }
            }
            return true
        }
        return false
    }
    
    
    func fillDataToCamera(groupName:String, cameraList:[CameraModel]) -> Void {
        self.groupName = groupName
        self.cameraList = cameraList
    }
}
