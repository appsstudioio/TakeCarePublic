//
//  BabyInfoTableViewCell.swift
//  TakeCare
//
//  Created by Lim on 2019/11/11.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift

let babyInfoTableViewCellIdentifier: String = "BabyInfoTableViewCell"
let babyInfoTableViewCellHeight: CGFloat = 70.0
class BabyInfoTableViewCell: UITableViewCell {
    enum BabyCellType {
        case settingType
        case infoType
    }
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var babyNameLabel: UILabel!
    @IBOutlet weak var babyBirthLabel: UILabel!
    @IBOutlet weak var babyImageView: UIImageView!
    @IBOutlet weak var babyMainHelpLabel: UILabel!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var boxViewLeftMarginConstrint: NSLayoutConstraint!
    @IBOutlet weak var boxViewRightMarginConstrint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        babyNameLabel.font         = UIFont(fontsStyle: .regular, size: 12)
        babyBirthLabel.font        = UIFont(fontsStyle: .regular, size: 10)
        babyMainHelpLabel.font     = UIFont(fontsStyle: .regular, size: 12)
        babyMainHelpLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(cellType: BabyCellType, data: RLMChildInfo?) {
        if cellType == .settingType {
            boxViewLeftMarginConstrint.constant = 0
            boxViewRightMarginConstrint.constant = 0
        } else if cellType == .infoType {
            boxViewLeftMarginConstrint.constant = 10
            boxViewRightMarginConstrint.constant = 10
        }
        
        babyMainHelpLabel.isHidden = true
        if let data = data {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy년 MM월 dd일"
            let year  = (data.birthday.betweenDates(toDate: Date(), component: [.year])?.year ?? 0 ) + 1
            let month = (data.birthday.betweenDates(toDate: Date(), component: [.month])?.month ?? 0 )
            let dday  = (data.birthday.betweenDates(toDate: Date(), component: [.day])?.day ?? 0) + 1
            babyNameLabel.text = data.name + (month <= 36 ? " (\(month)개월)" : " (\(year)살)" )
            babyBirthLabel.text = dateFormatter.string(from: data.birthday) + (month <= 36 ? " (D+\(dday)일)"  : " (\(month)개월)")
            if data.sex == 0 {
                babyImageView.image = UIImage.init(icon: .emoji(.genderMale), size: CGSize(width: 35, height: 35), textColor: .white, backgroundColor: .clear)
                babyImageView.backgroundColor = AppColorList().boyMainColor
                babyImageView.setBorderRadius(width: 1, color: AppColorList().boyMainColor, radius: 25)
                babyMainHelpLabel.textColor = AppColorList().boyMainColor
            } else {
                babyImageView.image = UIImage.init(icon: .emoji(.genderFemale), size: CGSize(width: 35, height: 35), textColor: .white, backgroundColor: .clear)
                babyImageView.backgroundColor = AppColorList().girlMainColor
                babyImageView.setBorderRadius(width: 1, color: AppColorList().girlMainColor, radius: 25)
                babyMainHelpLabel.textColor = AppColorList().girlMainColor
            }
            
            if data.mainFlag {
                babyMainHelpLabel.isHidden = false
            }
            
            
            
        } else {
            babyImageView.image = UIImage.init(icon: .googleMaterialDesign(.personAdd), size: CGSize(width: 35, height: 35), textColor: AppColorList().textColorDarkGray, backgroundColor: .clear)
            babyImageView.setBorderRadius(width: 1, color: AppColorList().textColorDarkGray, radius: 25)
            babyNameLabel.text = "등록된 아이 정보가 없습니다."
            babyBirthLabel.text = "아이를 등록해 주세요."
        }
    }
    
}
