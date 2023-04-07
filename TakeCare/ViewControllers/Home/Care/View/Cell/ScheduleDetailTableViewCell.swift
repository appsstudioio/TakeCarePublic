//
//  ScheduleTableViewCell.swift
//  TakeCare
//
//  Created by Lim on 2019/12/11.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var timeIconView: UIView!
    @IBOutlet weak var timeLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var helpLabelBox: PaddingLabel!

    static let cellIdentifier: String = "ScheduleDetailTableViewCell"
    let scheduleDetailTableViewCellHeight: CGFloat = 90

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        boxView.backgroundColor = AppColorList().tableCellBgColor
        helpLabelBox.edgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 9, right: 7)
        helpLabelBox.backgroundColor = AppColorList().helpBgColor
        helpLabelBox.isHidden = true
        
        helpLabelBox.font = UIFont(fontsStyle: .regular, size: 10)
        timeLabel.font    = UIFont(fontsStyle: .regular, size: 10)
        titleLabel.font   = UIFont(fontsStyle: .regular, size: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: RLMChildVCNScheduleInfo) {
        timeIconView.setBorderRadius(width: 1, color: AppColorList().timeLineColor, radius: 5)
        helpLabelBox.setBorderRadius(width: 1, color: AppColorList().timeLineColor, radius: 5)
        let endDateString =  data.endDate.toString(format: "yyyy년 MM월 dd일 (E)")
        timeLabel.text = data.startDate.toString(format: "yyyy년 MM월 dd일 (E)") + " ~ " + endDateString
        titleLabel.text = data.title
        if data.message != "" {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.minimumLineHeight = 18
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(fontsStyle: .regular, size: 10) as Any,
                                                             .paragraphStyle: paragraphStyle,
                                                             .foregroundColor: AppColorList().textColorLightGray]
            helpLabelBox.attributedText = NSAttributedString(string: data.message, attributes: attributes)

            let height = helpLabelBox.attributedText?.height(withConstrainedWidth: (UIScreen.main.bounds.width - 50)) ?? 0
            helpLabelBox.isHidden = false
            boxView.frame = CGRect(x: 10.0,
                                   y: 0,
                                   width: (UIScreen.main.bounds.width - 20),
                                   height: (scheduleDetailTableViewCellHeight + height))
        } else {
            helpLabelBox.attributedText = NSMutableAttributedString(string: "")
            helpLabelBox.isHidden = true
            boxView.frame = CGRect(x: 10.0,
                                   y: 0,
                                   width: (UIScreen.main.bounds.width - 20),
                                   height: scheduleDetailTableViewCellHeight)
        }
    }
    
    func noneData(chileFlag: Bool) {
        timeIconView.setBorderRadius(width: 1, color: AppColorList().timeLineColor, radius: 5)
        timeLabel.text = Date().toString(format: "yyyy년 MM월 dd일 (EEEE)")
        if chileFlag {
            // 일정이 없을때
            titleLabel.text = "등록된 아이 정보가 없어요. 지금 등록하세요."
        } else {
            // 일정이 없을때
            titleLabel.text = "예정된 일정이 없습니다."
        }

        boxView.frame = CGRect(x: 10.0,
                               y: 0,
                               width: (UIScreen.main.bounds.width - 20),
                               height: scheduleDetailTableViewCellHeight)
    }
 
}
