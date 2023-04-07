//
//  MoreViewTableViewCell.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

let moreViewTableViewCellIdentifier: String = "MoreViewTableViewCell"
let moreViewTableViewCellHeight: CGFloat = 60.0
class MoreViewTableViewCell: UITableViewCell {
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var menuTitleLabel: UILabel!
    @IBOutlet weak var menuSubTitleLabel: UILabel!
    @IBOutlet weak var menuArrowImageView: UIImageView!
    @IBOutlet weak var menuBottomLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        menuTitleLabel.font    = UIFont(fontsStyle: .regular, size: 13)
        menuSubTitleLabel.font = UIFont(fontsStyle: .regular, size: 13)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
