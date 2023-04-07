//
//  TimeWeatherDetailTableViewHeaderView.swift
//  TakeCare
//
//  Created by Lim on 2019/10/08.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import Solar
import RealmSwift
import CoreLocation

let timeWeatherDetailTHeaderViewHeight: CGFloat = 70.0
class TimeWeatherDetailHeaderView: UIView {
    var boxView = UIView()
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontsStyle: .regular, size: 14.0)
        label.textColor = AppColorList().textColorDarkText
        return label
    }()
    var maxTempIconImageView = UIImageView()
    var maxTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontsStyle: .regular, size: 10.0)
        label.textColor = AppColorList().weatherTempMaxColor
        return label
    }()
    var minTempIconImageView = UIImageView()
    var minTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontsStyle: .regular, size: 10.0)
        label.textColor = AppColorList().weatherTempMinColor
        return label
    }()
    var sunriseImageView = UIImageView()
    var sunriseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontsStyle: .regular, size: 10.0)
        label.textColor = AppColorList().textColorDarkGray
        return label
    }()
    var sunsetImageView = UIImageView()
    var sunsetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontsStyle: .regular, size: 10.0)
        label.textColor = AppColorList().textColorDarkGray
        return label
    }()
    var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = AppColorList().lineColor
        return lineView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setUI()
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   func setUI() {
        self.addSubview(boxView)
        boxView.frame = CGRect(x: 10, y:(self.frame.size.height < timeWeatherDetailTHeaderViewHeight ? 0 : 10), width: (self.frame.size.width - 20), height: (timeWeatherDetailTHeaderViewHeight - 10))
        boxView.backgroundColor = AppColorList().tableCellBgColor
        boxView.roundCorners(corners: [.topRight, .topLeft], radius: 5)
    
        let views = [titleLabel, maxTempIconImageView, maxTempLabel, minTempIconImageView, minTempLabel, sunriseImageView, sunriseLabel, sunsetImageView, sunsetLabel, lineView]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            boxView.addSubview($0)
        }
    
        let iconSize: CGFloat = 10
        titleLabel.anchor(top: boxView.topAnchor, left: boxView.leftAnchor, bottom: nil, right: boxView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: -10, width: 0, height: 25)
        
        minTempIconImageView.image = UIImage.init(icon: .weather(.thermometerExterior), size: CGSize(width: iconSize, height: iconSize), textColor: AppColorList().weatherTempMinColor, backgroundColor: .clear)
        minTempIconImageView.anchor(top: nil, left: boxView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: iconSize, height: iconSize)
        minTempIconImageView.centerYAnchor.constraint(equalTo: minTempLabel.centerYAnchor, constant: 0).isActive = true
        minTempLabel.anchor(top: titleLabel.bottomAnchor, left: minTempIconImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        maxTempIconImageView.image = UIImage.init(icon: .weather(.thermometer), size: CGSize(width: iconSize, height: iconSize), textColor: AppColorList().weatherTempMaxColor, backgroundColor: .clear)
        maxTempIconImageView.anchor(top: nil, left: minTempLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: iconSize, height: iconSize)
        maxTempIconImageView.centerYAnchor.constraint(equalTo: maxTempLabel.centerYAnchor, constant: 0).isActive = true
        maxTempLabel.anchor(top: titleLabel.bottomAnchor, left: maxTempIconImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        sunriseImageView.image = UIImage.init(icon: .weather(.sunrise), size: CGSize(width: iconSize, height: iconSize), textColor: AppColorList().textColorDarkGray, backgroundColor: .clear)
        sunriseImageView.anchor(top: nil, left: maxTempLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: iconSize, height: iconSize)
        sunriseImageView.centerYAnchor.constraint(equalTo: sunriseLabel.centerYAnchor, constant: 0).isActive = true
        sunriseLabel.anchor(top: titleLabel.bottomAnchor, left: sunriseImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        sunsetImageView.image = UIImage.init(icon: .weather(.sunset), size: CGSize(width: iconSize, height: iconSize), textColor: AppColorList().textColorDarkGray, backgroundColor: .clear)
        sunsetImageView.anchor(top: nil, left: sunriseLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: iconSize, height: iconSize)
        sunsetImageView.centerYAnchor.constraint(equalTo: sunsetLabel.centerYAnchor, constant: 0).isActive = true
        sunsetLabel.anchor(top: titleLabel.bottomAnchor, left: sunsetImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    
        lineView.anchor(top: nil, left: boxView.leftAnchor, bottom: boxView.bottomAnchor, right: boxView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        lineView.backgroundColor = AppColorList().lineColor
    }

    func updateHeaderView(data: ForecastDayModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko")
        let dateTime = dateFormatter.date(from: data.date) ?? Date()

        dateFormatter.dateFormat = "MM월 dd일 EEEE"
        titleLabel.text = dateFormatter.string(from: dateTime)
        minTempLabel.text = "\(data.day?.mintemp_c ?? 0)°"
        maxTempLabel.text = "\(data.day?.maxtemp_c ?? 0)°"
        dateFormatter.dateFormat = "HH:mm"
        sunriseLabel.text = data.astro?.sunrise
        sunsetLabel.text = data.astro?.sunset
    }
}
