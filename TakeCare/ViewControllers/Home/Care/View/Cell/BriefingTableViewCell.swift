//
//  BriefingTableViewCell.swift
//  TakeCare
//
//  Created by Lim on 2019/10/29.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import Solar
import CoreLocation
import RealmSwift

class BriefingTableViewCell: UITableViewCell {
    static let cellIdentifier: String = "BriefingTableViewCell"

    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var messageTextView: UITextView!

    let skeletonView: SkeletonGradientView = {
        let view = SkeletonGradientView()
        view.backgroundColor = AppColorList().skeletonStartPointColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    struct textBoldData {
        let textBoldString: String
        let textBoldColor: UIColor
        let boldFlag: Bool
        let allReplaceFlag: Bool

        init(text: String, color: UIColor, bold: Bool, replace: Bool) {
            self.textBoldString = text
            self.textBoldColor = color
            self.boldFlag = bold
            self.allReplaceFlag = replace
        }
    }

    var boldTextList: [textBoldData] = []
    var textList: [String] = []
    var attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        boxView.backgroundColor = AppColorList().tableCellBgColor
        messageTextView.textColor = AppColorList().textColorDarkGray
        messageTextView.font = UIFont(fontsStyle: .regular, size: 12)

        self.contentView.addSubview(skeletonView)
        skeletonView.anchor(top: boxView.topAnchor, left: boxView.leftAnchor, bottom: boxView.bottomAnchor, right: boxView.rightAnchor,
                            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        skeletonView.gradientLayer.colors = [AppColorList().skeletonStartPointColor.cgColor,
                                             AppColorList().skeletonEndPointColor.cgColor,
                                             AppColorList().skeletonStartPointColor.cgColor]
        self.slide()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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


    func setData(viewModel: CareViewModel) {
        self.stopSliding()
        attributedString = dateBriefing(viewModel: viewModel)
        attributedString.append(weatherBriefing(viewModel: viewModel))
        attributedString.append(dustBriefing(viewModel: viewModel))
        messageTextView.attributedText = attributedString
    }
}

extension BriefingTableViewCell {
    private func attributesTitleText(text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 20
        paragraphStyle.lineBreakMode = .byCharWrapping
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = UIFont(fontsStyle: .regular, size: 13) as Any
        attributes[.foregroundColor] = AppColorList().textColorDarkGray
        attributes[.paragraphStyle] = paragraphStyle

        let tempAttr = NSMutableAttributedString(string: text, attributes: attributes)
        if textList.count > 0 {
            for tempStr in textList {
                let numberBullet = "∙ "
                paragraphStyle.headIndent = (numberBullet as NSString).size(withAttributes: attributes).width
                tempAttr.append(NSMutableAttributedString(string: (numberBullet + tempStr), attributes: attributes))
            }
        }

        if boldTextList.count > 0 {
            for boldStyle in boldTextList {
                if boldStyle.allReplaceFlag {
                    var range = NSRange(location: 0, length: tempAttr.length)
                    var rangeArr = [NSRange]()
                    while (range.location != NSNotFound) {
                        range = (tempAttr.string as NSString).range(of: boldStyle.textBoldString, options: .caseInsensitive, range: range)
                        rangeArr.append(range)
                        if (range.location != NSNotFound) {
                            range = NSRange(location: range.location + range.length, length: tempAttr.length - (range.location + range.length))
                        }
                    }

                    rangeArr.forEach { (range) in
                        tempAttr.addAttributes([.font: (boldStyle.boldFlag == true ? UIFont(fontsStyle: .bold, size: 13) : UIFont(fontsStyle: .regular, size: 13)), .foregroundColor: boldStyle.textBoldColor], range: range)
                    }
                } else {
                    let tempValueRange = (tempAttr.string as NSString).range(of: boldStyle.textBoldString)
                    tempAttr.addAttributes([.font: (boldStyle.boldFlag == true ? UIFont(fontsStyle: .bold, size: 13) : UIFont(fontsStyle: .regular, size: 13)), .foregroundColor: boldStyle.textBoldColor], range: tempValueRange)

                }
            }
        }

        boldTextList.removeAll()
        textList.removeAll()
        return tempAttr
    }

    private func setBoldTextData(text: String, color: UIColor, bold: Bool, replace: Bool = false) {
        boldTextList.append(textBoldData(text: text, color: color, bold: bold, replace: replace))
    }

    private func dateBriefing(viewModel: CareViewModel) -> NSMutableAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.locale = Locale(identifier: "ko")

        var reString: String = ""
        let (holiDate, holiDateName) = SQLiteManager.shared.getHolidayInfo(query: "SELECT * FROM HOLIDAY_INFO WHERE hdate = '\(Date().toString(format: "yyyy-MM-dd"))' ")
        if let hdate = holiDate, let dateName = holiDateName {
            dateFormatter.dateFormat = "MM월 dd일 " + dateName
            reString = dateFormatter.string(from: hdate.toDate(format: "yyyy-MM-dd")!)
            setBoldTextData(text: reString, color: AppColorList().redColor, bold: true)
        } else {
            dateFormatter.dateFormat = "MM월 dd일 EEEE"
            reString = dateFormatter.string(from: Date())
            setBoldTextData(text: reString, color: AppColorList().textColorDarkGray, bold: true)
        }

        var birthdayStr = ""
        if let childArray = viewModel.childInfoList, childArray.count > 0 {
            dateFormatter.dateFormat = "yyyyMMdd"
            for data in childArray {
                if dateFormatter.string(from: data.birthday) == dateFormatter.string(from: Date()) {
                    if birthdayStr == "" {
                        birthdayStr = data.name
                    } else {
                        birthdayStr += ", " + data.name
                    }
                }
            }
        }

        reString += " 브리핑을 시작할께요.\n"
        if birthdayStr != "" {
            textList.append("오늘은 " + birthdayStr + "의 생일 입니다.\n")
        }
        return attributesTitleText(text: reString)
    }

    private func weatherBriefing(viewModel: CareViewModel) -> NSMutableAttributedString {
        guard let currentData = viewModel.currentData, viewModel.forecastData.count > 0 else { return NSMutableAttributedString(string: "") }
        guard let astro = viewModel.forecastData.first?.astro, let day = viewModel.forecastData.first?.day else { return NSMutableAttributedString(string: "") }

        let reString: String = "\n오늘의 날씨 정보예요.\n"

        textList.append("일출시간 " + astro.sunrise + ", 일몰시간 " + astro.sunset + "\n")
        setBoldTextData(text: astro.sunrise, color: AppColorList().textColorDarkGray, bold: true)
        setBoldTextData(text: astro.sunset, color: AppColorList().textColorDarkGray, bold: true)

        textList.append("최저기온 \(day.mintemp_c)°, 최고기온 \(day.maxtemp_c)°\n")
        setBoldTextData(text: "\(day.mintemp_c)°", color: AppColorList().weatherTempMinColor, bold: true)
        setBoldTextData(text: "\(day.maxtemp_c)°", color: AppColorList().weatherTempMaxColor, bold: true)

        let tempString = String(format: "체감온도 %.1f°", currentData.feelslike_c)
        textList.append("날씨 \(currentData.condition?.text ?? ""), \(tempString)\n")
        setBoldTextData(text: currentData.condition?.text ?? "", color: AppColorList().textColorDarkGray, bold: true)
        setBoldTextData(text: String(format: "%.1f°", currentData.feelslike_c), color: AppColorList().textColorDarkGray, bold: true)

        // 비, 소나기, 눈 예보
        if day.daily_will_it_rain > 0 {
            textList.append("오늘은 비가 내릴 예정이에요. 비올 확률은 \(viewModel.forecastData.first?.day?.daily_chance_of_rain ?? 0)% 외출시 우산을 준비하세요.\n")
            setBoldTextData(text: "오늘은 비가 내릴 예정이에요.", color: AppColorList().weatherTempMinColor, bold: true)
            setBoldTextData(text: "외출시 우산을 준비하세요.", color: AppColorList().weatherTempMinColor, bold: true)
        } else if day.daily_will_it_snow > 0 && day.daily_will_it_rain > 0 {
            textList.append("오늘은 비 또는 눈이 내릴 예정이에요. 비올 확률은 \(viewModel.forecastData.first?.day?.daily_chance_of_rain ?? 0)% 외출시 우산을 준비하세요.\n")
            setBoldTextData(text: "오늘은 비 또는 눈이 내릴 예정이에요.", color: AppColorList().weatherTempMinColor, bold: true)
            setBoldTextData(text: "외출시 우산을 준비하세요.", color: AppColorList().weatherTempMinColor, bold: true)
        } else if day.daily_will_it_snow > 0 {
            textList.append("오늘은 눈이 내릴 예정이에요. 눈올 확률은 \(viewModel.forecastData.first?.day?.daily_chance_of_snow ?? 0)%\n")
            setBoldTextData(text: "오늘은 눈이 내릴 예정이에요.", color: AppColorList().weatherTempMinColor, bold: true)
        }

        // 습도
        let rehValue = currentData.humidity
        let dayTemp = currentData.temp_c
        var humidityString = "습도는 \(rehValue)%, "
        setBoldTextData(text: "\(rehValue)%", color: AppColorList().textColorDarkGray, bold: true)
        if rehValue < 30 {
            humidityString += "적정 습도 보다 낮음, "
            setBoldTextData(text: "적정 습도 보다 낮음", color: AppColorList().weatherTempMinColor, bold: true)
        } else if rehValue > 80 {
            humidityString += "적정 습도 보다 높음, "
            setBoldTextData(text: "적정 습도 보다 높음", color: AppColorList().weatherTempMaxColor, bold: true)
        } else {
            if dayTemp <= 15.0 {
                humidityString += ( rehValue >= 60 && rehValue <= 70 ? "쾌적" : "적정" ) + ", "
            } else if dayTemp <= 20.0 {
                humidityString += ( rehValue >= 50 && rehValue <= 60 ? "쾌적" : "적정" ) + ", "
            } else if dayTemp <= 23.0 {
                humidityString += ( rehValue >= 40 && rehValue <= 50 ? "쾌적" : "적정" ) + ", "
            } else {
                humidityString += ( rehValue >= 30 && rehValue <= 40 ? "쾌적" : "적정" ) + ", "
            }
            setBoldTextData(text: "쾌적", color: AppColorList().greenCustomColor, bold: true)
        }
        textList.append("\(humidityString)\n")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        dateFormatter.locale = Locale(identifier: "ko")
        let month = Int(dateFormatter.string(from: Date()))
        switch month {
        case 3, 4, 5:
            textList.append("봄 실내 적정 온도는 19~23°, 습도는 50% 상태로 유지\n")
        case 6, 7, 8:
            textList.append(" 여름 실내 적정 온도는 24~27°, 습도는 60% 상태로 유지\n")
        case 9, 10, 11:
            textList.append(" 가을 실내 적정 온도는 19~23°, 습도는 50% 상태로 유지\n")
        case 1, 2, 12:
            textList.append(" 겨울 실내 적정 온도는 18~21°, 습도는 40% 상태로 유지\n")
        default:
            break
        }
        return attributesTitleText(text: reString)
    }

    private func dustBriefing(viewModel: CareViewModel) -> NSMutableAttributedString {
        guard let airQuality = viewModel.currentData?.air_quality else { return  NSMutableAttributedString(string: "") }
        var reString = "\n대기환경지수는 "
        switch airQuality.us_epa_index {
        case 1:
            reString = reString + "좋음 단계예요.\n"
            textList.append("공기의 질이 좋고 대기 오염은 위험을 전혀 야기하지 않음\n")
            setBoldTextData(text: "좋음 단계예요.", color: AppColorList().dustColorSelectLevel1, bold: true)
        case 2:
            reString = reString + "보통 단계예요.\n"
            textList.append("대기 질은 수용 가능하나 일부 오염 물질의 경우 공기 오염에 민감한 사람들에게는 건강 상 우려가 될 수 있음\n")
            textList.append("어린이 및 성인 그리고 천식과 같은 호흡기 질환이 있는 사람은 장시간 야외 활동을 가급적 자제하고 외출시 마스크 착용\n")
            setBoldTextData(text: "보통 단계예요.", color: AppColorList().dustColorSelectLevel3, bold: true)
        case 3:
            reString = reString + "약간나쁨 단계예요.\n"
            textList.append("호흡기 질환자 또는 어린이 건강에 영향을 줄 수 있음\n")
            textList.append("어린이 및 성인 그리고 천식과 같은 호흡기 질환이 있는 사람은 장시간 야외 활동을 자제하고 외출시 마스크 착용\n")
            setBoldTextData(text: "약간나쁨 단계예요.", color: AppColorList().dustColorSelectLevel4, bold: true)
        case 4:
            reString = reString + "나쁨 단계예요.\n"
            textList.append("일반인의 건강에 영향을 미칠 수 있으며, 호흡기 질환자 또는 어린이의 경우 더 심각한 건강상의 영향을 미칠 수 있음\n")
            textList.append("어린이 및 성인 그리고 천식과 같은 호흡기 질환이 있는 사람은 장시간 야외 활동을 피해야하고 외출시 마스크 착용\n")
            setBoldTextData(text: "나쁨 단계예요.", color: AppColorList().dustColorSelectLevel5, bold: true)
        case 5:
            reString = reString + "매우나쁨 단계예요.\n"
            textList.append("응급 상활에 대한 건강 경고!! 전체 인구가 영향을 받을 가능성이 커요. 모든 실외 운동을 피해야함\n")
            textList.append("아이들의 경우 야외 활동 및 운동을 제한하고 외출시 마스크 착용\n")
            setBoldTextData(text: "매우나쁨 단계예요.", color: AppColorList().dustColorSelectLevel6, bold: true)
        case 6:
            reString = reString + "위험 단계예요.\n"
            textList.append("모든 사람들이 심각한 건강상의 영향을 받을 수 있음\n")
            textList.append("모든 야외 활동을 피하고 외출 시 마스크 착용\n")
            setBoldTextData(text: "위험 단계예요.", color: AppColorList().dustColorSelectLevel7, bold: true)
        default:
            break
        }

        return attributesTitleText(text: reString)
    }
}
