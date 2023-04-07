//
//  DustTableViewCell.swift
//  TakeCare
//
//  Created by DONGJU LIM on 03/10/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

class DustTableViewCell: UITableViewCell {
    @IBOutlet weak var boxView: UIView!

    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var graph1View: UIView!
    @IBOutlet weak var value1Label: UILabel!
    
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var graph2View: UIView!
    @IBOutlet weak var value2Label: UILabel!
    
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var graph3View: UIView!
    @IBOutlet weak var value3Label: UILabel!
    
    @IBOutlet weak var title4Label: UILabel!
    @IBOutlet weak var graph4View: UIView!
    @IBOutlet weak var value4Label: UILabel!
    
    @IBOutlet weak var title5Label: UILabel!
    @IBOutlet weak var graph5View: UIView!
    @IBOutlet weak var value5Label: UILabel!
    
    @IBOutlet weak var title6Label: UILabel!
    @IBOutlet weak var graph6View: UIView!
    @IBOutlet weak var value6Label: UILabel!
    
    @IBOutlet weak var box1WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var box2WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var box3WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var box4WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var box5WidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var box6WidthConstraint: NSLayoutConstraint!

    static let cellIdentifier: String = "DustTableViewCell"
    let lineWidthSize: CGFloat = 6.5
    // #EDEDED
    let graphBgColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        boxView.backgroundColor = AppColorList().tableCellBgColor
        
        let widthSize = (UIScreen.main.bounds.width - 20) / 3
        box1WidthConstraint.constant = widthSize
        box2WidthConstraint.constant = widthSize
        box3WidthConstraint.constant = widthSize
        box4WidthConstraint.constant = widthSize
        box5WidthConstraint.constant = widthSize
        box6WidthConstraint.constant = widthSize

        value1Label.font = UIFont(fontsStyle: .regular, size: 10)
        title2Label.font = UIFont(fontsStyle: .regular, size: 10)
        value2Label.font = UIFont(fontsStyle: .regular, size: 10)
        title3Label.font = UIFont(fontsStyle: .regular, size: 10)
        value3Label.font = UIFont(fontsStyle: .regular, size: 10)
        title4Label.font = UIFont(fontsStyle: .regular, size: 10)
        value4Label.font = UIFont(fontsStyle: .regular, size: 10)
        title5Label.font = UIFont(fontsStyle: .regular, size: 10)
        value5Label.font = UIFont(fontsStyle: .regular, size: 10)
        title6Label.font = UIFont(fontsStyle: .regular, size: 10)
        value6Label.font = UIFont(fontsStyle: .regular, size: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func attributesTitleText(title: String, value: String, markColor: UIColor, valueBold: Bool = false) -> NSMutableAttributedString {
        let tempString = title + "\n" + value
        let tempAttr = NSMutableAttributedString(string: tempString)
        let tempValueRange = (tempString as NSString).range(of: value)
        tempAttr.addAttributes([.font: (valueBold == true ? UIFont(fontsStyle: .bold, size: 8) : UIFont(fontsStyle: .regular, size: 8)), .foregroundColor: markColor], range: tempValueRange)
        return tempAttr
    }
    
    private func returnGraphStartValue(level: DustLevelValue, dustType: DustInfoType) -> CGFloat {
        switch level {
        case .level1:
            return 0
        case .level2:
            return 25
        case .level3:
            return 50
        case .level4:
            return 75
        case .level5:
            return 100
        case .level6:
            return 100
        case .level7:
            return 100
        }
    }
    
    func setData(data: AirQualityModel) {
        graph1View.layer.sublayers = nil
        graph2View.layer.sublayers = nil
        graph3View.layer.sublayers = nil
        graph4View.layer.sublayers = nil
        graph5View.layer.sublayers = nil
        graph6View.layer.sublayers = nil
        var startValue: CGFloat = 0
        data.o3 = ugm3ToPPM(value:data.o3, dustType: .o3)
        data.so2 = ugm3ToPPM(value:data.so2, dustType: .so2)
        data.co = ugm3ToPPM(value:data.co, dustType: .co)
        data.no2 = ugm3ToPPM(value:data.no2, dustType: .no2)
        // 초미세먼지 pm25
        graph1View.layer.circleDraw(AppColorList().dustColorNomalLevel1, lineWidth: lineWidthSize, circleSize: graph1View.bounds.width, startValue: 0, endValue: 25, animationFlag: false)
        graph1View.layer.circleDraw(AppColorList().dustColorNomalLevel2, lineWidth: lineWidthSize, circleSize: graph1View.bounds.width, startValue: 25, endValue: 50, animationFlag: false)
        graph1View.layer.circleDraw(AppColorList().dustColorNomalLevel3, lineWidth: lineWidthSize, circleSize: graph1View.bounds.width, startValue: 50, endValue: 75, animationFlag: false)
        graph1View.layer.circleDraw(AppColorList().dustColorNomalLevel4, lineWidth: lineWidthSize, circleSize: graph1View.bounds.width, startValue: 75, endValue: 100, animationFlag: false)
        let pm25Data = returnDustCellValue(data: data, dustType: .pm25)

        title1Label.attributedText = attributesTitleText(title: "초미세먼지", value: pm25Data.0, markColor: pm25Data.4, valueBold: true)
        value1Label.attributedText = attributesTitleText(title: String(format: "%.1f", data.pm2_5), value: "㎍/㎥", markColor: AppColorList().textColorLightGray)
        startValue = returnGraphStartValue(level: pm25Data.2, dustType: .pm25)
        graph1View.layer.circleDraw(pm25Data.4, lineWidth: lineWidthSize, circleSize: graph1View.bounds.width, startValue: startValue, endValue: pm25Data.3, animationFlag: true)

        // 미세먼지 pm10
        graph2View.layer.circleDraw(AppColorList().dustColorNomalLevel1, lineWidth: lineWidthSize, circleSize: graph2View.bounds.width, startValue: 0, endValue: 25, animationFlag: false)
        graph2View.layer.circleDraw(AppColorList().dustColorNomalLevel2, lineWidth: lineWidthSize, circleSize: graph2View.bounds.width, startValue: 25, endValue: 50, animationFlag: false)
        graph2View.layer.circleDraw(AppColorList().dustColorNomalLevel3, lineWidth: lineWidthSize, circleSize: graph2View.bounds.width, startValue: 50, endValue: 75, animationFlag: false)
        graph2View.layer.circleDraw(AppColorList().dustColorNomalLevel4, lineWidth: lineWidthSize, circleSize: graph2View.bounds.width, startValue: 75, endValue: 100, animationFlag: false)
        let pm10Data = returnDustCellValue(data: data, dustType: .pm10)
        title2Label.attributedText = attributesTitleText(title: "미세먼지", value: pm10Data.0, markColor: pm10Data.4, valueBold: true)
        value2Label.attributedText = attributesTitleText(title: String(format: "%.1f", data.pm10), value: "㎍/㎥", markColor: AppColorList().textColorLightGray)
        startValue = returnGraphStartValue(level: pm10Data.2, dustType: .pm10)
        graph2View.layer.circleDraw(pm10Data.4, lineWidth: lineWidthSize, circleSize: graph2View.bounds.width, startValue: startValue, endValue: pm10Data.3, animationFlag: true)

        // 오존 o3
        graph3View.layer.circleDraw(AppColorList().dustColorNomalLevel1, lineWidth: lineWidthSize, circleSize: graph3View.bounds.width, startValue: 0, endValue: 25, animationFlag: false)
        graph3View.layer.circleDraw(AppColorList().dustColorNomalLevel2, lineWidth: lineWidthSize, circleSize: graph3View.bounds.width, startValue: 25, endValue: 50, animationFlag: false)
        graph3View.layer.circleDraw(AppColorList().dustColorNomalLevel3, lineWidth: lineWidthSize, circleSize: graph3View.bounds.width, startValue: 50, endValue: 75, animationFlag: false)
        graph3View.layer.circleDraw(AppColorList().dustColorNomalLevel4, lineWidth: lineWidthSize, circleSize: graph3View.bounds.width, startValue: 75, endValue: 100, animationFlag: false)
        let o3Data = returnDustCellValue(data: data, dustType: .o3)
        title3Label.attributedText = attributesTitleText(title: "오존", value: o3Data.0, markColor: o3Data.4, valueBold: true)
        value3Label.attributedText = attributesTitleText(title: String(format: "%.4f", data.o3), value: "ppm", markColor: AppColorList().textColorLightGray)
        startValue = returnGraphStartValue(level: o3Data.2, dustType: .o3)
        graph3View.layer.circleDraw(o3Data.4, lineWidth: lineWidthSize, circleSize: graph3View.bounds.width, startValue: startValue, endValue: o3Data.3, animationFlag: true)

        // 아황산가스 so2
        graph4View.layer.circleDraw(AppColorList().dustColorNomalLevel1, lineWidth: lineWidthSize, circleSize: graph4View.bounds.width, startValue: 0, endValue: 25, animationFlag: false)
        graph4View.layer.circleDraw(AppColorList().dustColorNomalLevel2, lineWidth: lineWidthSize, circleSize: graph4View.bounds.width, startValue: 25, endValue: 50, animationFlag: false)
        graph4View.layer.circleDraw(AppColorList().dustColorNomalLevel3, lineWidth: lineWidthSize, circleSize: graph4View.bounds.width, startValue: 50, endValue: 75, animationFlag: false)
        graph4View.layer.circleDraw(AppColorList().dustColorNomalLevel4, lineWidth: lineWidthSize, circleSize: graph4View.bounds.width, startValue: 75, endValue: 100, animationFlag: false)
        let so2Data = returnDustCellValue(data: data, dustType: .so2)
        title4Label.attributedText = attributesTitleText(title: "아황산가스", value: so2Data.0, markColor: so2Data.4, valueBold: true)
        value4Label.attributedText = attributesTitleText(title: String(format: "%.3f", data.so2), value: "ppm", markColor: AppColorList().textColorLightGray)
        startValue = returnGraphStartValue(level: so2Data.2, dustType: .so2)
        graph4View.layer.circleDraw(so2Data.4, lineWidth: lineWidthSize, circleSize: graph4View.bounds.width, startValue: startValue, endValue: so2Data.3, animationFlag: true)

        // 이산화질소 no2
        graph5View.layer.circleDraw(AppColorList().dustColorNomalLevel1, lineWidth: lineWidthSize, circleSize: graph5View.bounds.width, startValue: 0, endValue: 25, animationFlag: false)
        graph5View.layer.circleDraw(AppColorList().dustColorNomalLevel2, lineWidth: lineWidthSize, circleSize: graph5View.bounds.width, startValue: 25, endValue: 50, animationFlag: false)
        graph5View.layer.circleDraw(AppColorList().dustColorNomalLevel3, lineWidth: lineWidthSize, circleSize: graph5View.bounds.width, startValue: 50, endValue: 75, animationFlag: false)
        graph5View.layer.circleDraw(AppColorList().dustColorNomalLevel4, lineWidth: lineWidthSize, circleSize: graph5View.bounds.width, startValue: 75, endValue: 100, animationFlag: false)
        let no2Data = returnDustCellValue(data: data, dustType: .no2)
        title5Label.attributedText = attributesTitleText(title: "이산화질소", value: no2Data.0, markColor: no2Data.4, valueBold: true)
        value5Label.attributedText = attributesTitleText(title: String(format: "%.3f", data.no2), value: "ppm", markColor: AppColorList().textColorLightGray)
        startValue = returnGraphStartValue(level: no2Data.2, dustType: .no2)
        graph5View.layer.circleDraw(no2Data.4, lineWidth: lineWidthSize, circleSize: graph5View.bounds.width, startValue: startValue, endValue: no2Data.3, animationFlag: true)

        // 일산화탄소 co
        graph6View.layer.circleDraw(AppColorList().dustColorNomalLevel1, lineWidth: lineWidthSize, circleSize: graph6View.bounds.width, startValue: 0, endValue: 25, animationFlag: false)
        graph6View.layer.circleDraw(AppColorList().dustColorNomalLevel2, lineWidth: lineWidthSize, circleSize: graph6View.bounds.width, startValue: 25, endValue: 50, animationFlag: false)
        graph6View.layer.circleDraw(AppColorList().dustColorNomalLevel3, lineWidth: lineWidthSize, circleSize: graph6View.bounds.width, startValue: 50, endValue: 75, animationFlag: false)
        graph6View.layer.circleDraw(AppColorList().dustColorNomalLevel4, lineWidth: lineWidthSize, circleSize: graph6View.bounds.width, startValue: 75, endValue: 100, animationFlag: false)
        let coData = returnDustCellValue(data: data, dustType: .co)
        title6Label.attributedText = attributesTitleText(title: "일산화탄소", value: coData.0, markColor: coData.4, valueBold: true)
        value6Label.attributedText = attributesTitleText(title: String(format: "%.3f", data.co), value: "ppm", markColor: AppColorList().textColorLightGray)
        startValue = returnGraphStartValue(level: coData.2, dustType: .co)
        graph6View.layer.circleDraw(coData.4, lineWidth: lineWidthSize, circleSize: graph6View.bounds.width, startValue: startValue, endValue: coData.3, animationFlag: true)
    }

    func returnDustCellValue(data: AirQualityModel, dustType: DustInfoType) -> (String, String, DustLevelValue, CGFloat, UIColor) {
        switch dustType {
        case .pm25:
            let value = data.pm2_5
            switch value {
            case 0...15:
                return("좋음", "", .level1, 25.0, AppColorList().dustColorSelectLevel1)
            case 16...35:
                return("보통", "", .level2, 50.0, AppColorList().dustColorSelectLevel3)
            case 36...75:
                return("나쁨", "", .level3, 75.0, AppColorList().dustColorSelectLevel4)
            default:
                return("매우나쁨", "", .level4, 100.0, AppColorList().dustColorSelectLevel6)
            }
        case .pm10:
            let value = data.pm10
            switch value {
            case 0...30:
                return("좋음", "", .level1, 25.0, AppColorList().dustColorSelectLevel1)
            case 31...80:
                return("보통", "", .level2, 50.0, AppColorList().dustColorSelectLevel3)
            case 81...150:
                return("나쁨", "", .level3, 75.0, AppColorList().dustColorSelectLevel4)
            default:
                return("매우나쁨", "", .level4, 100.0, AppColorList().dustColorSelectLevel6)
            }
        case .so2:
            let value = data.so2
            if value <= 0.02 {
                return("좋음", "", .level1, 25.0, AppColorList().dustColorSelectLevel1)
            } else if value <= 0.05 {
                return("보통", "", .level2, 50.0, AppColorList().dustColorSelectLevel3)
            } else if value <= 0.15 {
                return("나쁨", "", .level3, 75.0, AppColorList().dustColorSelectLevel4)
            } else {
                return("매우나쁨", "", .level4, 100.0, AppColorList().dustColorSelectLevel6)
            }
        case .o3:
            let value = data.o3
            if value <= 0.03 {
                return("좋음", "", .level1, 25.0, AppColorList().dustColorSelectLevel1)
            } else if value <= 0.09 {
                return("보통", "", .level2, 50.0, AppColorList().dustColorSelectLevel3)
            } else if value <= 0.15 {
                return("나쁨", "", .level3, 75.0, AppColorList().dustColorSelectLevel4)
            } else {
                return("매우나쁨", "", .level4, 100.0, AppColorList().dustColorSelectLevel6)
            }
        case .co:
            let value = data.co
           if value <= 2.0 {
                return("좋음", "", .level1, 25.0, AppColorList().dustColorSelectLevel1)
           } else if value <= 9.0 {
                return("보통", "", .level2, 50.0, AppColorList().dustColorSelectLevel3)
           } else if value <= 15.0 {
                return("나쁨", "", .level3, 75.0, AppColorList().dustColorSelectLevel4)
            } else {
                return("매우나쁨", "", .level4, 100.0, AppColorList().dustColorSelectLevel6)
            }
        case .no2:
            let value = data.no2
            if value <= 0.03 {
                return("좋음", "", .level1, 25.0, AppColorList().dustColorSelectLevel1)
            } else if value <= 0.06 {
                return("보통", "", .level2, 50.0, AppColorList().dustColorSelectLevel3)
            } else if value <= 0.2 {
                return("나쁨", "", .level3, 75.0, AppColorList().dustColorSelectLevel4)
            } else {
                return("매우나쁨", "", .level4, 100.0, AppColorList().dustColorSelectLevel6)
            }
        }
    }
}
