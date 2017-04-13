//
//  HomeTableViewCell.swift
//  CameraDemo
//
//  Created by HungHN on 4/4/17.
//  Copyright © 2017 Thuy Do Thanh. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var cameraId: UILabel!
    @IBOutlet weak var layoutView: UIView!
    @IBOutlet weak var cameraOnline: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if(selected) {
            layoutView.backgroundColor = UIColor.init(red: 61, green: 81, blue: 181)
        } else {
            layoutView.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        }
    }
    
    func showCamera(camera: CameraModel) {
        self.cameraName.text = camera.cameraName
        self.cameraId.text = camera.cameraID
        var image:UIImage!
        if(camera.isOnline)! {
            image = UIImage.init(named: "image_cam_online")
        } else {
            image = UIImage.init(named: "image_cam_offline")
        }
        
        self.cameraOnline.image = image
    }
}
