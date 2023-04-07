//
//  ASRulerControl.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2020/01/06.
//  Copyright © 2020 Apps Studio. All rights reserved.
//

import UIKit

@IBDesignable
class ASRulerControl: UIControl {
    enum RulerValueType : Int {
        case intValue = 0x11
        case floatValue
    }
    
    // 작은 눈금 거리 값
    let kMinorScaleDefaultSpacing: CGFloat = 60.0
    // 큰 눈금 크기
    let kMajorScaleDefaultLength: CGFloat = 20.0
    // 중간 눈금 크기
    let kMiddleScaleDefaultLength: CGFloat = 20.0
    // 작은 눈금 크기
    let kMinorScaleDefaultLength: CGFloat = 20.0
    // 눈금자 배경색상
    let kRulerDefaultBackgroundColor = UIColor.clear
    // 기본 눈금 색
    let kScaleDefaultColor = UIColor(red: 0.84, green: 0.84, blue: 0.84, alpha: 1.00)
    // 기본 눈금 글꼴 색상
    let kScaleDefaultFontColor = UIColor(red: 0.71, green: 0.71, blue: 0.71, alpha: 1.00)
    // 기본 글꼴 크기
    let kScaleDefaultFontSize: CGFloat = 13.0
    // 선택 눈금 색상
    let kIndicatorDefaultColor = UIColor(red: 0.47, green: 0.62, blue: 0.33, alpha: 1.00)
    // 선택 눈금 크기
    let kIndicatorDefaultLength: CGFloat = 20.0
    let LABEL_TAG = 0xdddd

    // 설정
    @IBInspectable var selectedValue: CGFloat = 0.0
    // 수직 스크롤，기본 NO
    @IBInspectable var verticalScroll = false
    // 최소값
    @IBInspectable var minValue: CGFloat = 0.0
    // 최대값
    @IBInspectable var maxValue: CGFloat = 100.0
    // 눈금 간격 값
    @IBInspectable var valueStep: CGFloat = 0.0
    // 작은 눈금자의 간격, 기본값 `8.0`
    @IBInspectable var minorScaleSpacing: CGFloat = 8.0
    // 최대 눈금자의 간격, 기본값 `40.0`
    @IBInspectable var majorScaleLength: CGFloat = 40.0
    // 중간 눈금자의 간격, 기본값 `25.0`
    @IBInspectable var middleScaleLength: CGFloat = 25.0
    // 작은 눈금자의 간격, 기본값 `10.0`
    @IBInspectable var minorScaleLength: CGFloat = 10.0
    // 눈금자 배경색상, 기본값 `clear`
    @IBInspectable var rulerBackgroundColor: UIColor = .clear
    // 눈금 색상，기본값 `lightGray`
    @IBInspectable var scaleColor: UIColor = .lightGray
    // 눈금 글꼴 색상，기본값 `darkGray`
    @IBInspectable var scaleFontColor: UIColor = .darkGray
    // 글꼴 크기，기본값 `10.0`
    @IBInspectable var scaleFontSize: CGFloat = 10.0
    // 눈금 선택 색상，기본값 `red`
    @IBInspectable var indicatorColor: UIColor = .red
    // 선택 눈금 크기，기본값 `40.0`
    @IBInspectable var indicatorLength: CGFloat = 40.0
    // 폰트
    @IBInspectable var font: UIFont?
    
    var scrollView: UIScrollView = UIScrollView(frame: UIScreen.main.bounds)
    var rulerImageView: UIImageView = UIImageView()
    var indicatorView: UIView = UIView()
    var indicatorLabelView: UILabel =  UILabel()
    var eRulerValueType: RulerValueType = .intValue
    
    // MARK: - 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if rulerImageView.image == nil {
            reloadRuler()
        }
        let size = bounds.size
        if verticalScroll {
           indicatorView.frame = CGRect(x: 0, y: size.height * 0.5, width: indicatorLength, height: 1)
        } else {
           // 소수점을 포함
           indicatorLabelView.frame = CGRect(x: (size.width - 80.0) * 0.5, y: 8.0, width: 80.0, height: 20.0)
           indicatorView.frame = CGRect(x: size.width * 0.5, y: size.height - indicatorLength, width: 1, height: indicatorLength)
        }

        // 스크롤 뷰의 컨텐츠 간격을 설정
        let textSize = maxValueTextSize()
        if verticalScroll {
           let offset = size.height * 0.5 - textSize.width
           scrollView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: offset, right: 0)
        } else {
           let offset = size.width * 0.5 - textSize.width
           scrollView.contentInset = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: offset)
        }
    }

    // MARK: - 설정 인터페이스
    private func setupUI() {
        // 기본 가로 스크롤
        verticalScroll = false

        // 스크롤보기
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.addSubview(rulerImageView)

        // 표시보기
        indicatorView.backgroundColor = indicatorColor
        addSubview(indicatorView)

        // 선택된 글자 보기
        let fontSize = scaleFontSize * UIScreen.main.scale * 0.5
        font = UIFont.systemFont(ofSize: fontSize)
        indicatorLabelView.backgroundColor = .white
        indicatorLabelView.textColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        indicatorLabelView.textAlignment = .center
        indicatorLabelView.font = font!
        addSubview(indicatorLabelView)
    }
}

extension ASRulerControl {
    // MARK: - 속성 설정
    func setSelectedValue(selectedValue: CGFloat) {
        if selectedValue < minValue || selectedValue > maxValue || valueStep <= 0 {
            return
        }
        self.selectedValue = selectedValue
        self.sendActions(for: .valueChanged)
        
        let spacing = minorScaleSpacing
        let size = self.bounds.size
        let textSize = maxValueTextSize()
        var offset: CGFloat = 0
        
        // 계산 오프셋 (offset)
        let steps = stepsWithValue(value: selectedValue)
        
        if verticalScroll {
            offset = size.height * 0.5 - textSize.width - steps * spacing
            scrollView.contentOffset = CGPoint(x: 0, y: -offset)
        } else {
            offset = size.width * 0.5 - textSize.width - steps * spacing
            scrollView.contentOffset = CGPoint(x: -offset, y: 0)
        }
    }
    
    // MARK: - 绘制标尺相关方法 (도면 축척 상관 방법)
    // 새로 고침 통치자
    private func reloadRuler() {
        guard let image = rulerImage() else { return }
        rulerImageView.image = image
        rulerImageView.backgroundColor = rulerBackgroundColor
        rulerImageView.sizeToFit()
        scrollView.contentSize = rulerImageView.image!.size
       
        // 가로 눈금자를 맞춥니다
        if !verticalScroll {
            var rect = rulerImageView.frame
            rect.origin.y = scrollView.bounds.size.height - rulerImageView.image!.size.height
            rulerImageView.frame = rect
        }
       
        // 초기 값 업데이트
        if eRulerValueType == .intValue {
            indicatorLabelView.text = String.init(format: "%d", Int(selectedValue))
        } else if eRulerValueType == .floatValue {
            indicatorLabelView.text = String.init(format: "%.01f", selectedValue)
        }
    }
    
    // 눈금자 생성
    private func rulerImage() -> UIImage? {
        // 1. 상수계산
        let steps = stepsWithValue(value: maxValue)
        if steps == 0 {
            return nil
        }
            
        // 이미지의 가로 크기 구함
        let textSize = maxValueTextSize()
        let height = majorScaleLength + textSize.height + 10
        let startX = textSize.width
        let rect = CGRect(x: 0, y: 0, width: steps * minorScaleSpacing + 2 * startX, height: height)
            
        // 2. 이미지를 그리기
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
            
        // 1> 눈금을 그린다. (round(_valueStep * 10.0) / 10.0)
        let path = UIBezierPath()
        for i in stride(from: minValue, through: maxValue, by: valueStep) {
            // 큰 눈금을 그립니다
            // CGFloat x = (i - _minValue) / _valueStep * minorScaleSpacing * 10 + startX
            let x = (i - minValue) / valueStep * minorScaleSpacing + startX
            path.move(to: CGPoint(x: x, y: height))
            path.addLine(to: CGPoint(x: x, y: (height - majorScaleLength)))

            // 가로선 그리기
            if ((i + valueStep) <= maxValue) {
                let next_x = ((i + valueStep) - minValue) / ((valueStep * minorScaleSpacing) + startX)
                path.move(to: CGPoint(x: x, y: height))
                path.addLine(to: CGPoint(x: next_x, y: height))
            }

            if (i == maxValue) {
                break
            }

            // 작은 눈금을 그립니다
            #if false
//            for (NSInteger j = 1 j < 10 j++) {
//                CGFloat scaleX = x + j * minorScaleSpacing
//                [path moveToPoint:CGPointMake(scaleX, height)]
//
//                CGFloat scaleY = height - ((j == 5) ? middleScaleLength : minorScaleLength)
//                [path addLineToPoint:CGPointMake(scaleX, scaleY)]
//            }
            #endif
        }
        scaleColor.set()
        path.stroke()
        
        // 2> 그리기 스케일 값
        let strAttributes = scaleTextAttributes() as! [NSAttributedString.Key : Any]
        for i in stride(from: minValue, through: maxValue, by: valueStep) {
            var str: NSString = ""
            if(valueStep < 1)
            {
                str = NSString.init(format: "%.1f", i)
            }
            else
            {
                str = NSString.init(format: "%.0f", i)
            }
            let constraintRect = CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude)
            var strRect = str.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: strAttributes, context: nil)
            
            strRect.origin.x = (i - minValue) / valueStep * minorScaleSpacing + startX - strRect.size.width * 0.5
            strRect.origin.y = 8
            str.draw(in: strRect, withAttributes: strAttributes)
        }

        var result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
            
        // 3. 회전 이미지
        if !verticalScroll {
            return result
        }
        
        // 새로 크기일때... 눈금자를 회전한다.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.height, height: rect.size.width), false, UIScreen.main.scale)
        UIGraphicsGetCurrentContext()!.rotate(by: (.pi / 2))
        UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -(result?.size.height)!)
        result?.draw(in: rect)
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result

    }
    
    // 최소 계산 및 지정 value 단계들 사이, 즉 : 도면 스케일의 총 개수
    func stepsWithValue(value: CGFloat) -> CGFloat {
        if minValue >= value || valueStep <= 0 {
            return 0
        }

        // return (value - _minValue) / _valueStep * 10
        return (value - minValue) / valueStep
    }

    //  수평 방향 계산을 그립니다 `문자의 최대 수` 크기
    func maxValueTextSize() -> CGSize {
        let scaleText = NSNumber(value: Double(maxValue)).description
        let size = scaleText.boundingRect(with: CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude),
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: scaleTextAttributes() as? [NSAttributedString.Key : Any],
                                                       context: nil).size
        return CGSize(width: floor(size.width), height: floor(size.height))
    }

    //  텍스트는 사전 속성
    func scaleTextAttributes() -> [AnyHashable : Any]? {
//        let fontSize = scaleFontSize * UIScreen.main.scale * 0.5
        return [
            NSAttributedString.Key.foregroundColor: scaleFontColor,
            NSAttributedString.Key.font: font!
        ]
    }

    // MARK: - 스케일 설정
    func getMinorScaleSpacing() -> CGFloat {
        if minorScaleSpacing <= 0 {
            minorScaleSpacing = kMinorScaleDefaultSpacing
        }
        return minorScaleSpacing
    }

    func getMajorScaleLength() -> CGFloat {
        if majorScaleLength <= 0 {
            majorScaleLength = kMajorScaleDefaultLength
        }
        return majorScaleLength
    }

    func getMiddleScaleLength() -> CGFloat {
        if middleScaleLength <= 0 {
            middleScaleLength = kMiddleScaleDefaultLength
        }
        return middleScaleLength
    }

    func getMinorScaleLength() -> CGFloat {
        if minorScaleLength <= 0 {
            minorScaleLength = kMinorScaleDefaultLength
        }
        return minorScaleLength
    }

    func getScaleFontSize() -> CGFloat {
        if scaleFontSize <= 0 {
            scaleFontSize = kScaleDefaultFontSize
        }
        return scaleFontSize
    }

    func getIndicatorLength() -> CGFloat {
        if indicatorLength <= 0 {
            indicatorLength = kIndicatorDefaultLength
        }
        return indicatorLength
    }
}

// MARK: - UIScrollViewDelegate
extension ASRulerControl: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let spacing = minorScaleSpacing
        let size = bounds.size
        let textSize = maxValueTextSize()
        if (verticalScroll) {
            let offset = targetContentOffset.pointee.y + size.height * 0.5 - textSize.width
            _ = Int(offset / spacing + 0.5)
            
//            targetContentOffset.pointee.y = -(size.height * 0.5 - textSize.width - steps * spacing) - 0.5
        } else {
            let offset = targetContentOffset.pointee.x + size.width * 0.5 - textSize.width
            _ = (NSInteger)(offset / spacing + 0.5)
            
//            targetContentOffset.pointee.x = -(size.width * 0.5 - textSize.width - steps * spacing) - 0.5
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!(scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating)) {
            return
        }
        
        let spacing = minorScaleSpacing
        let size = bounds.size
        let textSize = maxValueTextSize()
        
        var offset: CGFloat = 0.0
        if verticalScroll {
            offset = scrollView.contentOffset.y + size.height * 0.5 - textSize.width
        } else {
            offset = scrollView.contentOffset.x + size.width * 0.5 - textSize.width
        }
        
        let steps = CGFloat(offset / spacing + 0.5)
        let value = minValue + steps * valueStep
        if (value != selectedValue && (value >= minValue && value <= maxValue)) {
            selectedValue = value
            // 초기 값 업데이트
            if eRulerValueType == .intValue {
                indicatorLabelView.text = String.init(format: "%d", Int(selectedValue))
            } else if eRulerValueType == .floatValue {
                indicatorLabelView.text = String.init(format: "%.01f", selectedValue)
            }
            
            if(eRulerValueType == .intValue)
            {
                indicatorLabelView.text = String.init(format: "%d", Int(selectedValue))
            }
            else
            {
                indicatorLabelView.text = String.init(format: "%.01f", selectedValue)
            }
            self.sendActions(for: .valueChanged)
        }
    }
}
