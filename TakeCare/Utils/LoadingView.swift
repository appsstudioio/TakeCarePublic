//
//  LoadingView.swift
//  TakeCare
//
//  Created by Lim on 05/08/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit
import SpringIndicator

class LoadingView: UIView {
    var bgView = UIView(frame: UIScreen.main.bounds)
    let indicator = SpringIndicator()
    
    let indicatorWidthSize: CGFloat = 40
    let indicatorHeightSize: CGFloat = 40
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingView {
    func setUI() {
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        bgView.isUserInteractionEnabled = true
        let widthOffsetX = ((UIScreen.main.bounds.width - indicatorWidthSize) / 2)
        let widthOffsetY = ((UIScreen.main.bounds.height - indicatorHeightSize) / 2)
        let indicator = SpringIndicator(frame: CGRect(x: widthOffsetX,
                                                      y: widthOffsetY,
                                                      width: indicatorWidthSize,
                                                      height: indicatorHeightSize))
        indicator.lineColor = AppColorList().lineColor
        indicator.lineWidth = 4.5
        bgView.addSubview(indicator)
        indicator.start()
        
        self.addSubview(bgView)
    }
    
    func removeLoadingView(){
        self.removeFromSuperview()
    }
}


