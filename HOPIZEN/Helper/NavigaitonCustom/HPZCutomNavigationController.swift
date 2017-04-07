//
//  HPZCutomNavigationController.swift
//  HOPIZEN
//
//  Created by Thuy Do Thanh on 12/13/16.
//  Copyright © 2016 Thuy Do Thanh. All rights reserved.
//

import UIKit

class HPZCutomNavigationController: UINavigationController {
// ThuyDT
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupNaviController()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //MARK setupNavi
    
    func setupNaviController()-> Void {
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont.systemFont(ofSize: 15)]
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = UIColor(netHex: 0x5456AC)
    }
    func reversedArray(inputArr:NSArray?) ->NSArray? {
        let array:NSMutableArray? = NSMutableArray(capacity: (inputArr?.count)!)
        let enumerator:NSEnumerator? = inputArr?.reverseObjectEnumerator()
        for element in enumerator! {
            array?.add(element)
        }
        return array
    }
    
    func addLeftBtnWithImg(img:UIImage?, targer:AnyObject?, action:Selector) -> Void {
        let barBtn = self.barButtonWithImage(img: img, targer: targer, action: action)
        self.topViewController?.navigationItem.leftBarButtonItem = barBtn
    }
    
    
    func addRightBtnWithImg(img:UIImage?, targer:AnyObject?, action:Selector) -> Void {
        let barBtn = self.barButtonWithImage(img: img, targer: targer, action: action)
        self.topViewController?.navigationItem.rightBarButtonItem = barBtn
    }
    
    func addLeftBtnWithBackgroundImage(bgImg: UIImage?, title:String?, titleColor:UIColor?, targer:AnyObject?, action:Selector) -> Void {
        var barBtn: UIBarButtonItem
        if bgImg != nil {
            barBtn = self.barButtonWithBackgroundImage(img: bgImg!, title: title, titleColor: titleColor, targer: targer, action: action)
        } else {
            barBtn = UIBarButtonItem(title: title, style: .plain, target: targer, action:action)
            barBtn.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: UIControlState.normal) // Tuyen add for edit color in barbuttonitem
        }
        
        self.topViewController?.navigationItem.leftBarButtonItem = barBtn
    }
    
    
    func addRightBtnWithBackgroundImage(bgImg: UIImage?, title:String?, titleColor:UIColor?, targer:AnyObject?, action:Selector) -> Void {
        var barBtn: UIBarButtonItem
        if bgImg != nil {
            barBtn = self.barButtonWithBackgroundImage(img: bgImg!, title: title, titleColor: titleColor, targer: targer, action: action)
        } else {
            barBtn = UIBarButtonItem(title: title, style: .plain, target: targer, action:action)
            barBtn.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: UIControlState.normal)  // Tuyen add for edit color in barbuttonitem
        }
        
        self.topViewController?.navigationItem.rightBarButtonItem = barBtn
    }
    
    func addRightBtnWithTitle(title:String?, titleColor:UIColor?, target:AnyObject?, action:Selector) -> Void {
        let barBtn = UIBarButtonItem(title: title, style: .plain, target: target, action:action)
        barBtn.setTitleTextAttributes([NSForegroundColorAttributeName : titleColor!], for: UIControlState.normal)
    
        self.topViewController?.navigationItem.rightBarButtonItem = barBtn
    }
    
    func addLeftBtnWithTitle(title:String?, titleColor:UIColor?, target:AnyObject?, action:Selector) -> Void {
        let barBtn = UIBarButtonItem(title: title, style: .plain, target: target, action:action)
        barBtn.setTitleTextAttributes([NSForegroundColorAttributeName : titleColor!], for: UIControlState.normal)
        
        self.topViewController?.navigationItem.leftBarButtonItem = barBtn
    }
    
    //    func setColorForitem(enable : Bool, isLeft : Bool) {
    //        let color = enable ? UIColor.blackColor : UIColor.grayColor
    //        var barBtn: UIBarButtonItem
    //        if  isLeft {
    //            barBtn = (self.topViewController?.navigationItem.leftBarButtonItem)!
    //            if color == UIColor.grayColor() {
    //                BLMainFrameHelper.setUserPanGesture(false)
    //            } else {
    //                BLMainFrameHelper.setUserPanGesture(true)
    //            }
    //        } else {
    //            barBtn = (self.topViewController?.navigationItem.rightBarButtonItem)!
    //        }
    //        barBtn.setTitleTextAttributes([NSForegroundColorAttributeName : color], forState: UIControlState.Normal)
    //        if color == UIColor.blackColor() {
    //            barBtn.enabled = true
    //        } else {
    //            barBtn.enabled = false
    //        }
    //    }
    
    func  setTextForBarButtonItem(title : String, isLeft : Bool) {
        var barBtn: UIBarButtonItem
        if  isLeft {
            barBtn = (self.topViewController?.navigationItem.leftBarButtonItem)!
        } else {
            barBtn = (self.topViewController?.navigationItem.rightBarButtonItem)!
        }
        barBtn.title = title;
    }
    
    func addBackBtn( targer:AnyObject?, action:Selector) -> Void {
        let barBtn:UIBarButtonItem? = self.barButtonWithImage(img: UIImage(named: "ic_back"), targer: targer, action: action)
        self.topViewController?.navigationItem.leftBarButtonItem = barBtn
    }
    
    func barButtonWithImage(img:UIImage?, targer:AnyObject?, action:Selector) -> UIBarButtonItem {
        let width:CGFloat = (img?.size.width)!
        let button = UIButton(frame:CGRect(x: 0, y: 0, width: width, height: img!.size.height))
        button.setImage(img, for: .normal)
        button.addTarget(targer, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    func barButtonWithBackgroundImage(img:UIImage, title:String?, titleColor:UIColor?, targer:AnyObject?, action:Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        button.setBackgroundImage(img, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.addTarget(targer, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    
    //    func addMultiBtns(btnContent:[AnyObject]?,leftOrRight:Bool?,targer:AnyObject?,actions:[Selector]?) -> NSArray? {
    //        if btnContent!.count > 0 && actions!.count > 0 && btnContent?.count == actions!.count {
    //            var btnArray:[UIBarButtonItem] = []
    //            for idx in (0...(btnContent?.count)! - 1).reversed(){
    //                let cont:AnyObject = btnContent![idx]
    //                let act: Selector = actions![idx] as Selector
    //                if cont.isKind(UIImage.self) == true {
    //                    let barBtn = self.barButtonWithImage(img: cont as? UIImage, targer: targer, action: act)
    //                    btnArray.append(barBtn)
    //                } else if cont.isKind(NSString) == true {
    //                    let barBtn = UIBarButtonItem(title: cont as? String, style: .plain, target: targer, action:act)
    //                    btnArray.append(barBtn)
    //                }
    //            }
    //
    //            if leftOrRight == true {
    //                self.topViewController?.navigationItem.setLeftBarButtonItems(btnArray, animated: true)
    //            } else {
    //                self.topViewController?.navigationItem.setRightBarButtonItems(btnArray, animated: true)
    //            }
    //
    //            return self.reversedArray(btnArray)
    //        } else {
    //            return nil
    //        }
    //    }
    
    func removeLeftButton() {
        self.topViewController?.navigationItem.leftBarButtonItem = nil
    }
    
    func removeRightButton() {
        self.topViewController?.navigationItem.rightBarButtonItem = nil
    }


}
