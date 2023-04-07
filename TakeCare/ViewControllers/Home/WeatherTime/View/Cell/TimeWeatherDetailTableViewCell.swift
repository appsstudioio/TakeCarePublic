//
//  TimeWeatherDetailTableViewCell.swift
//  TakeCare
//
//  Created by Lim on 2019/10/08.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift

class TimeWeatherDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var timeIconView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var tempValueLabel: UILabel!
    @IBOutlet weak var weatherStatusLabel: UILabel!
    @IBOutlet weak var rainPercentLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    let skeletonView: SkeletonGradientView = {
        let view = SkeletonGradientView()
        view.backgroundColor = AppColorList().skeletonStartPointColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    static let cellIdentifier: String = "TimeWeatherDetailTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        boxView.backgroundColor = AppColorList().tableCellBgColor
        timeLabel.font = UIFont(fontsStyle: .regular, size: 10)
        tempValueLabel.font = UIFont(fontsStyle: .regular, size: 20)
        weatherStatusLabel.font = UIFont(fontsStyle: .regular, size: 13)
        rainPercentLabel.font = UIFont(fontsStyle: .regular, size: 10)

        self.contentView.addSubview(skeletonView)
        skeletonView.anchor(top: boxView.topAnchor, left: boxView.leftAnchor, bottom: boxView.bottomAnchor, right: boxView.rightAnchor,
                            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        skeletonView.gradientLayer.colors = [AppColorList().skeletonStartPointColor.cgColor,
                                             AppColorList().skeletonEndPointColor.cgColor,
                                             AppColorList().skeletonStartPointColor.cgColor]
        bottomLineView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: HourWeatherModel) {
        timeIconView.setBorderRadius(width: 1, color: AppColorList().timeLineColor, radius: 5)

        let dateFormatter = DateFormatter()
        let dateTime = data.time.toDate(format: "yyy-MM-dd HH:mm") ?? Date()
        dateFormatter.dateFormat = "dd일 HH시"
        tempValueLabel.text = "\(data.temp_c)" + "°"
        timeLabel.text = dateFormatter.string(from: dateTime)
        weatherStatusLabel.text = data.condition?.text ?? ""
        let iconUrl = getWeatherIcon(code: data.condition?.code ?? 113, isDay: data.is_day)
        let processor = DefaultImageProcessor.default
        if let url = URL(string: iconUrl) {
            weatherIconImageView.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [ .processor(processor),
                                                   .scaleFactor(UIScreen.main.scale),
                                                   .transition(.fade(0.4)),
                                                   .cacheOriginalImage]

            weatherIconImageView.kf.setImage(with: url, placeholder: nil, options: options, completionHandler: nil)
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        paragraphStyle.minimumLineHeight = 10
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(fontsStyle: .regular, size: 10) as Any,
                                                         .paragraphStyle: paragraphStyle,
                                                         .foregroundColor: AppColorList().textColorLightGray]
        var rainPercentString = "체감온도 \(data.feelslike_c)°"
        if data.will_it_snow == 1 && data.will_it_rain == 0 {
            rainPercentString += " 눈올확률 \(data.chance_of_snow)%"
        } else if data.will_it_snow == 0 && data.will_it_rain == 1 {
            rainPercentString += " 강수확률 \(data.chance_of_rain)%"
        } else {
            rainPercentString += " 강수확률 \(data.chance_of_rain)%"
        }
        rainPercentString += " 습도 \(data.humidity)%"

        let attrString = NSMutableAttributedString(string: rainPercentString, attributes: attributes)
        attrString.addAttribute(.foregroundColor,
                                value: AppColorList().textColorDarkGray,
                                range: rainPercentString.getRange(text: "\(data.feelslike_c)°"))
        attrString.addAttribute(.font,
                                value: UIFont(fontsStyle: .bold, size: 10),
                                range: rainPercentString.getRange(text: "\(data.feelslike_c)°"))
        attrString.addAttribute(.foregroundColor,
                                value: AppColorList().textColorDarkGray,
                                range: rainPercentString.getRange(text: "\(data.humidity)%"))
        attrString.addAttribute(.font,
                                value: UIFont(fontsStyle: .bold, size: 10),
                                range: rainPercentString.getRange(text: "\(data.humidity)%"))
        attrString.addAttribute(.foregroundColor,
                                value: AppColorList().textColorDarkGray,
                                range: rainPercentString.getRange(text: "\(data.chance_of_rain)%"))
        attrString.addAttribute(.font,
                                value: UIFont(fontsStyle: .bold, size: 10),
                                range: rainPercentString.getRange(text: "\(data.chance_of_rain)%"))
        rainPercentLabel.attributedText = attrString
        stopSliding()
    }

    func slide() {
        skeletonView.isHidden = false
        skeletonView.slide()
    }

    /// A convenient way to stop sliding the `GradientOwner`'s corresponding `gradientLayers`.
    func stopSliding() {
        skeletonView.stopSliding()
        skeletonView.isHidden = true
    }
}
