//
//  Networks+ErrorHandling.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/12/24.
//  Copyright © 2021 Apps Studio. All rights reserved.
//

import Foundation
import UIKit

class NetworksErrorHandling {
    static func weatherErrorCode(statusCode: Int, errorCode: Int) {
        guard let viewVC = UIApplication.topViewController() else { return }
        var message: String = ""
        switch statusCode {
            case 400:
                if errorCode == 1003 {
                    message = "Parameter 'q' not provided."
                } else if errorCode == 1005 {
                    message = "API request url is invalid"
                } else if errorCode == 1006 {
                    message = "No location found matching parameter 'q'"
                } else if errorCode == 9999 {
                    message = "Internal application error."
                }
            case 401:
                if errorCode == 1002 {
                    message = "API key not provided."
                } else if errorCode == 2006 {
                    message = "API key provided is invalid"
                }
            case 403:
                if errorCode == 2007 {
                    message = "API key has exceeded calls per month quota."
                } else if errorCode == 2008 {
                    message = "API key has been disabled."
                }
            default:
                break
        }
        toastView(view: viewVC.view, message: message)
    }
}
