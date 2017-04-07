//
//  HPZConstant.swift
//  HOPIZEN
//
//  Created by Thuy Do Thanh on 12/13/16.
//  Copyright © 2016 Thuy Do Thanh. All rights reserved.
//

import UIKit

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate

let screenBounds                                = UIScreen.main.bounds
let screenSize                                  = screenBounds.size

let screenWidth                                 = screenSize.width
let screenHeight                                = screenSize.height


func Tlog(logMessage:String, functionName: String = #function, line:Int = #line, lClass:String = #file) {
    print("FILE-\(lClass):FUCN-\(functionName):LINE-\(line): \(logMessage)")
}


struct GoogleKey {
    static let API_KEY  = "AIzaSyDDLa5Do1zXKOs1YAWFVazh4tbXy4JWv-A"
}

struct PDevice {
    static let key_uuid_app     = "KEY_UUID_APP"
    static let os_name          = "IOS"
    static let os_version       = UIDevice.current.systemVersion
    
}


struct defaultsKeys {
    static let keyUserName = "userNameStringKey"
    static let keyPassword = "passwordStringKey"
    static let keyServerAddress = "serverAddressStringKey"
    static let keyHasSavePassword = "savePasswordStringKey"
}

enum PickerType:Int {
    case FromType = 1
    case ToType = 2
    case NameType = 3
    case SpeedType = 4
}
