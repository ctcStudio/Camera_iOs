//
//  GpsInfoModle.swift
//  CameraDemo
//
//  Created by HungHN on 4/12/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class GpsInfoModel: HPZBaseEntity {
    var lat:Double? = 0
    var northOrSouth:String? = "N"
    var log:Double? = 0
    var eastOrWest:String? = "E"
    var date:String? = ""
    var utcTime:String? = ""
    var alt:String? = ""
    var speed:Double? = 0
    var course:String? = ""
    var address:String? = ""

    
    
    override func paserStringRespon(message: String) -> Bool {
        print("respon:\(message)")
        let rangeBegin = message.range(of: "<GPS>")?.upperBound
        let rangeEnd = message.range(of: "<GPS>", options: .backwards)?.lowerBound
        let range = rangeBegin!..<rangeEnd!
        let contentMessage = message.substring(with: range)
        let gpsInfoString = contentMessage.replace(target: "+CGPSINFO:", withString: "")
        let splitData = gpsInfoString.components(separatedBy: ",")
        
        if splitData.count > 0 {
            let pos = Double.init(splitData[0])
            self.lat = self.convertGpsToDecimal(pos: pos!)
        }
        if splitData.count > 1 {
            self.northOrSouth = splitData[1]
        }
        if splitData.count > 2 {
            let pos = Double.init(splitData[2])
            self.log = self.convertGpsToDecimal(pos: pos!)
        }
        if splitData.count > 3 {
            self.eastOrWest = splitData[3]
        }
        if splitData.count > 4 {
            self.date = splitData[4]
        }
        if splitData.count > 5 {
            self.utcTime = splitData[5]
        }
        if splitData.count > 6 {
            self.alt = splitData[6]
        }
        
        if splitData.count > 7 {
            self.speed = Swift.abs(Double.init(splitData[7])!)
        }
        
        if splitData.count > 8 {
            self.course = splitData[8]
        }
        return true
    }
    func convertGpsToDecimal(pos:Double) -> Double {
        let degrees:Int = Int.init(pos) / 100
        let minutes:Double = pos - Double.init((degrees * 100))
        return (Double.init(degrees) + minutes / Double.init(60))
    }
    
    func getSpeedKM() -> Double {
        return self.speed! * 1.852
    }
}
