//
//  Extensions+CALayer.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

extension CALayer {
    // swiftlint:disable function_parameter_count
    // https://stackoverflow.com/questions/15704163/draw-shadow-only-from-3-sides-of-uiview
    func applySketchShadow(color: UIColor,
                           alpha: CGFloat,
                           x offsetX: CGFloat,
                           y offsetY: CGFloat,
                           blur: CGFloat,
                           spread: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = Float(alpha)
        shadowOffset = CGSize(width: offsetX, height: offsetY)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let drawX = -spread
            let rect = bounds.insetBy(dx: drawX, dy: drawX)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    // swiftlint:enable function_parameter_count

    func fadeAnimation(duration: CFTimeInterval,
                       subtype: CATransitionSubtype,
                       timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                       transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.fade
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func moveInAnimation(duration: CFTimeInterval,
                         subtype: CATransitionSubtype,
                         timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                         transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.moveIn
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func pushAnimation(duration: CFTimeInterval,
                       subtype: CATransitionSubtype,
                       timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                       transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func revealAnimation(duration: CFTimeInterval,
                         subtype: CATransitionSubtype,
                         timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                         transitionType: CATransitionType = .push ) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.duration = duration
        animation.type = CATransitionType.reveal
        animation.subtype = subtype
        self.add(animation, forKey: transitionType.rawValue)
    }

    func bottomAnimation(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }

    func topAnimation(duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromBottom
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }

    func makeShadow(color: UIColor,
                    x offsetX: CGFloat = 0,
                    y offsetY: CGFloat = 0,
                    blur: CGFloat = 0,
                    spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = 1
        shadowOffset = CGSize(width: offsetX, height: offsetY)
        shadowRadius = blur / 2
        if spread == 0 {
            shadowPath = nil
        } else {
            let rect = bounds.insetBy(dx: -spread, dy: -spread)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    func addBorder(_ arrEdge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arrEdge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
            default:
                break
            }
            border.backgroundColor = color.cgColor
            self.addSublayer(border)
        }
    }

    func circleDraw(_ color: UIColor, lineWidth: CGFloat, circleSize: CGFloat, startValue: CGFloat = 0.0, endValue: CGFloat, animationFlag: Bool) {
        let circle = CAShapeLayer()
        let m_pi_2: Double = (.pi / 2)
        circle.path = UIBezierPath(arcCenter: CGPoint(x: (circleSize/2), y: (circleSize/2)), radius: (circleSize/2), startAngle: CGFloat(m_pi_2), endAngle: CGFloat((2 * .pi) + m_pi_2), clockwise: true).cgPath
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = color.cgColor
        circle.lineWidth = lineWidth
        circle.strokeStart = (startValue / 100)
        circle.strokeEnd = (endValue / 100)

        if animationFlag == true {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.3
            animation.isRemovedOnCompletion = false
            animation.fromValue = NSNumber(value: Float(startValue / 100))
            animation.toValue = NSNumber(value: Float(endValue / 100.0))
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "linear"))

            circle.add(animation, forKey: "drawCircleAnimation")
        }
        self.addSublayer(circle)
    }
}

extension CABasicAnimation {
    /// A convenient way to apply a `GradientTransition` to a `CABasicAnimation`.
    func apply(from: CGPoint, to: CGPoint) {
        fromValue = NSValue(cgPoint: from)
        toValue = NSValue(cgPoint: to)
    }
}

public extension CAGradientLayer {
    /// The key used for the sliding animation.
    private static let kSlidingAnimationKey = "com.appsstudio.TakeCare.Skeleton.SlidingAnimation"

    /**
    Slide a `CAGradientLayer` in a particular direction.

    - Important: If using `group`, modify the `CAAnimationGroup` responsibly. Setting the `CAAnimationGroup`s `animations` here **will overwrite the slide animations**.

    - parameter dir: The `Direction` to slide the `CAGradientLayer` in.

    - parameter group: A function that takes in and returns a `CAAnimationGroup`. Useful to modify the `CAAnimationGroup` that is used to animate the `CAGradientLayer`. By default, no modifications are made to the corresponding `CAAnimationGroup`.
    */
    func slide(duration: CFTimeInterval = 1.5, group: ((CAAnimationGroup) -> Void) = { _ in }) {
        let startPointAnim = CABasicAnimation(keyPath: #keyPath(startPoint))
        startPointAnim.apply(from: CGPoint(x: -1, y: 0.5), to: CGPoint(x: 1, y: 0.5))

        let endPointAnim = CABasicAnimation(keyPath: #keyPath(endPoint))
        endPointAnim.apply(from: CGPoint(x: 0, y: 0.5), to: CGPoint(x: 2, y: 0.5))

        let animGroup = CAAnimationGroup()
        animGroup.animations = [startPointAnim, endPointAnim]
        animGroup.duration = duration
        animGroup.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animGroup.repeatCount = .infinity

        group(animGroup)
        add(animGroup, forKey: CAGradientLayer.kSlidingAnimationKey)
    }

    /// Stop sliding the `CAGradientLayer`.
    func stopSliding() {
        removeAnimation(forKey: CAGradientLayer.kSlidingAnimationKey)
    }
}
