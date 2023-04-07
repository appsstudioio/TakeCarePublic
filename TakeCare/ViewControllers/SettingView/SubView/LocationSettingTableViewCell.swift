//
//  LocationSettingTableViewCell.swift
//  TakeCare
//
//  Created by Lim on 31/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

let locationSettingTableViewCellIdentifier: String = "LocationSettingTableViewCell"
let locationSettingTableViewCellHeight: CGFloat = 60.0
class LocationSettingTableViewCell: UITableViewCell {
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationSettingButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        locationSettingButton.setImage(UIImage.init(icon: .fontAwesomeSolid(.checkSquare), size: locationSettingButton.frame.size, textColor: AppColorList().textColorLightGray, backgroundColor: .clear), for: .normal)
        locationSettingButton.setImage(UIImage.init(icon: .fontAwesomeSolid(.checkSquare), size: locationSettingButton.frame.size, textColor: AppColorList().greenColor, backgroundColor: .clear), for: .selected)
        locationSettingButton.isUserInteractionEnabled = false
        locationNameLabel.font = UIFont(fontsStyle: .regular, size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
