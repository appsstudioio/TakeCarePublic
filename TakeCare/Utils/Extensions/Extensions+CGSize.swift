//
//  Extensions+CGSize.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/11/10.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation
import AVFoundation

extension CGSize {
    // Calculates the best height of the image for available width.
    func height(forWidth width: CGFloat) -> CGFloat {
        let boundingRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat(MAXFLOAT)
        )
        let rect = AVMakeRect(
            aspectRatio: self,
            insideRect: boundingRect
        )
        return rect.size.height
    }
}
