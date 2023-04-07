//
//  Extensions+UIView.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

extension UIView {
    // notaTODO: add Shadow
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   offset: CGSize = CGSize(width: 0.0, height: 0.0),
                   fx frameX: CGFloat = 0,
                   fy frameY: CGFloat = 0,
                   color: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1),
                   shadowRadius: CGFloat = 5.0) {

        self.layer.masksToBounds = false
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = color.cgColor

        let path = UIBezierPath()
        var posX: CGFloat = frameX
        var posY: CGFloat = frameY
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height

        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if top {
            posY += (shadowRadius+1)
        }
        if bottom {
            viewHeight -= (shadowRadius+1)
        }
        if left {
            posX += (shadowRadius+1)
        }
        if right {
            viewWidth -= (shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: posX, y: posY))
        // Move to the Bottom Left Corner, this will cover left edges
        path.addLine(to: CGPoint(x: posX, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        path.addLine(to: CGPoint(x: viewWidth, y: posY))
        // Move back to the initial point, this will cover the top edge
        path.close()
        self.layer.shadowPath = path.cgPath
    }

    // // https://stackoverflow.com/questions/1372977/given-a-view-how-do-i-get-its-viewcontroller
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    // swiftlint:disable function_parameter_count
    func anchor(top: NSLayoutYAxisAnchor?,
                left: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?,
                right: NSLayoutXAxisAnchor?,
                paddingTop: CGFloat,
                paddingLeft: CGFloat,
                paddingBottom: CGFloat,
                paddingRight: CGFloat,
                width: CGFloat,
                height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }

        if let  right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }

        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    // swiftlint:enable function_parameter_count

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    func setBorderRadius(width: CGFloat, color: UIColor, radius: CGFloat) {
        self.layer.borderWidth = CGFloat(width)
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }

    // https://stackoverflow.com/questions/62434770/how-add-corner-radius-to-dashed-border-around-an-uiview
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: UIColor, width: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineDashPattern = pattern
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.lineWidth = width
        borderLayer.path = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: .allCorners,
                                        cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.layer.addSublayer(borderLayer)
    }

    func screenshot(viewArea: Bool = false) -> UIImage {
        if let scrollView = self as? UIScrollView {
            if viewArea == false {
                // 스크롤뷰 전체영역
                let savedContentOffset = scrollView.contentOffset
                let savedFrame = scrollView.frame

                UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, false, UIScreen.main.scale)
                scrollView.contentOffset = .zero
                self.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
                let context = UIGraphicsGetCurrentContext()!
                context.interpolationQuality = .high
                self.layer.render(in: context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                scrollView.contentOffset = savedContentOffset
                scrollView.frame = savedFrame
                return image!
            } else {
                // 보이는 부분만
                UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, false, UIScreen.main.scale)
                let offset = scrollView.contentOffset
                let thisContext = UIGraphicsGetCurrentContext()!
                thisContext.interpolationQuality = .high
                thisContext.translateBy(x: -offset.x, y: -offset.y)
                scrollView.layer.render(in: thisContext)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image!
            }
        }

        // UIGraphicsBeginImageContext(self.bounds.size)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale )
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .high
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!

    }

    func shake(count: Float = 3, for duration: TimeInterval = 0.5, withTranslation translation: Float = 5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}
