//
//  WeatherTableViewCell.swift
//  TakeCare
//
//  Created by Lim on 25/09/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import RealmSwift
import Lottie


class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var currentTempValueLabel: UILabel!
    @IBOutlet weak var currentTempValueUnitLabel: UILabel!
    @IBOutlet weak var currentTempStatusLabel: UILabel!
    @IBOutlet weak var currentChillValueLabel: UILabel!
    let skeletonView: SkeletonGradientView = {
        let view = SkeletonGradientView()
        view.backgroundColor = AppColorList().skeletonStartPointColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    static let cellIdentifier: String = "WeatherTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        boxView.backgroundColor        = AppColorList().tableCellBgColor
        currentTempValueLabel.font     = UIFont(fontsStyle: .bold, size: 35)
        currentTempValueUnitLabel.font = UIFont(fontsStyle: .bold, size: 15)
        currentTempStatusLabel.font    = UIFont(fontsStyle: .regular, size: 17)
        currentChillValueLabel.font    = UIFont(fontsStyle: .regular, size: 10)

        self.contentView.addSubview(skeletonView)
        skeletonView.anchor(top: boxView.topAnchor, left: boxView.leftAnchor, bottom: boxView.bottomAnchor, right: boxView.rightAnchor,
                            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        skeletonView.gradientLayer.colors = [AppColorList().skeletonStartPointColor.cgColor,
                                             AppColorList().skeletonEndPointColor.cgColor,
                                             AppColorList().skeletonStartPointColor.cgColor]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setData(data: CurrentWeatherModel) {
        currentTempValueLabel.text = "\(data.temp_c)"
        currentTempStatusLabel.text = data.condition?.text ?? ""

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.minimumLineHeight = 10
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(fontsStyle: .regular, size: 10) as Any,
                                                         .paragraphStyle: paragraphStyle,
                                                         .foregroundColor: AppColorList().textColorDarkGray]
        // , \(getNewWCT(Tdum: data.temp_c, Wdum: data.wind_kph))°
        let subString = "습도 \(data.humidity)%\n체감온도 \(data.feelslike_c)°"
        let attrString = NSMutableAttributedString(string: subString, attributes: attributes)
        attrString.addAttribute(.foregroundColor, value: AppColorList().textColorDarkText, range: subString.getRange(text: "\(data.humidity)%"))
        attrString.addAttribute(.font, value: UIFont(fontsStyle: .bold, size: 10), range: subString.getRange(text: "\(data.humidity)%"))
        attrString.addAttribute(.foregroundColor, value: AppColorList().textColorDarkText, range: subString.getRange(text: "\(data.feelslike_c)°"))
        attrString.addAttribute(.font, value: UIFont(fontsStyle: .bold, size: 10), range: subString.getRange(text: "\(data.feelslike_c)°"))
        currentChillValueLabel.attributedText = attrString

        let iconUrl = getWeatherIcon(code: data.condition?.code ?? 113, isDay: data.is_day)
        if let url = URL(string: iconUrl) {
            weatherIconImageView.kf.setImage(with: url, placeholder: nil, options: nil, completionHandler: nil)
        }
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
