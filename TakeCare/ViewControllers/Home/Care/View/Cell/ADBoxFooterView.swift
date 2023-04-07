//
//  ADBoxFoterView.swift
//  TakeCare
//
//  Created by Lim on 25/09/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import UIKit

class ADBoxFooterView: UIView {
    enum BannerAdType {
        case small(width: CGFloat, height:CGFloat)
        case middle(width: CGFloat, height:CGFloat)
        case big(width: CGFloat, height:CGFloat)
    }
    
    let adMarkerImageView = UIImageView()
    let boxView = UIView()
    let bannerFrameView = UIView()
    let helfMsgLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColorList().textColorLightGray
        label.textAlignment = .left
        label.font = UIFont(fontsStyle: .regular, size: 9.0)
        label.text = "kakao 맞춤형 광고입니다."
        return label
    }()
    var bannerType: BannerAdType = .small(width: 320, height: 50)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    convenience init(frame: CGRect, type: BannerAdType) {
        self.init(frame: frame)
        self.bannerType = type
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ADBoxFooterView {
    private func setUI() {
        boxView.translatesAutoresizingMaskIntoConstraints = false
        boxView.backgroundColor = AppColorList().tableCellBgColor
        self.addSubview(boxView)
        
        let views = [ adMarkerImageView, bannerFrameView, helfMsgLabel]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            boxView.addSubview($0)
        }
        let marginLeftRight: CGFloat = (self.frame.size.width == 320 ? 0 : 10)
        
        switch bannerType {
        case .small(let width, let height):
            
            boxView.anchor(top: self.topAnchor,
                           left: self.leftAnchor,
                           bottom: self.bottomAnchor,
                           right: self.rightAnchor,
                           paddingTop: 10,
                           paddingLeft: marginLeftRight,
                           paddingBottom: -10,
                           paddingRight: -marginLeftRight,
                           width: 0,
                           height: 0)
            boxView.setBorderRadius(width: 1.0, color: .clear, radius: 5)
            
            bannerFrameView.centerXAnchor.constraint(equalTo: boxView.centerXAnchor, constant: 0).isActive = true
            bannerFrameView.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 10).isActive = true
            bannerFrameView.widthAnchor.constraint(equalToConstant: width).isActive = true
            bannerFrameView.heightAnchor.constraint(equalToConstant: height).isActive = true
        case .middle(let width, let height):
            boxView.anchor(top: self.topAnchor,
                           left: self.leftAnchor,
                           bottom: self.bottomAnchor,
                           right: self.rightAnchor,
                           paddingTop: 10,
                           paddingLeft: marginLeftRight,
                           paddingBottom: -10,
                           paddingRight: -marginLeftRight,
                           width: 0,
                           height: 0)
            boxView.setBorderRadius(width: 1.0, color: .clear, radius: 5)
            
            bannerFrameView.centerXAnchor.constraint(equalTo: boxView.centerXAnchor, constant: 0).isActive = true
                   bannerFrameView.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 10).isActive = true
            bannerFrameView.widthAnchor.constraint(equalToConstant: width).isActive = true
            bannerFrameView.heightAnchor.constraint(equalToConstant: height).isActive = true
        case .big(let width, let height):
            boxView.anchor(top: self.topAnchor,
                           left: self.leftAnchor,
                           bottom: self.bottomAnchor,
                           right: self.rightAnchor,
                           paddingTop: 10,
                           paddingLeft: marginLeftRight,
                           paddingBottom: -10,
                           paddingRight: -marginLeftRight,
                           width: 0,
                           height: 0)
            boxView.setBorderRadius(width: 1.0, color: .clear, radius: 5)
            
            bannerFrameView.centerXAnchor.constraint(equalTo: boxView.centerXAnchor, constant: 0).isActive = true
                   bannerFrameView.topAnchor.constraint(equalTo: boxView.topAnchor, constant: 10).isActive = true
            bannerFrameView.widthAnchor.constraint(equalToConstant: width).isActive = true
            bannerFrameView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        adMarkerImageView.leadingAnchor.constraint(equalTo: bannerFrameView.leadingAnchor, constant: 0).isActive = true
        adMarkerImageView.topAnchor.constraint(equalTo: bannerFrameView.bottomAnchor, constant: 5).isActive = true
        adMarkerImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        adMarkerImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        adMarkerImageView.image = UIImage.init(icon: .fontAwesomeSolid(.infoCircle),
                                               size: CGSize(width: 20, height: 20),
                                               textColor: AppColorList().textColorLightGray,
                                               backgroundColor: .clear)
        
        helfMsgLabel.leftAnchor.constraint(equalTo: adMarkerImageView.rightAnchor, constant: 2).isActive = true
        helfMsgLabel.centerYAnchor.constraint(equalTo: adMarkerImageView.centerYAnchor).isActive = true
        helfMsgLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        helfMsgLabel.trailingAnchor.constraint(equalTo: bannerFrameView.trailingAnchor, constant: 0).isActive = true
    }
}
