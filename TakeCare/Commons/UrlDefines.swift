//
//  urlDefines.swift
//  TakeCare
//
//  Created by Lim on 11/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation

#if DEBUG
let weatherAPIHostUrl: String = "https://api.weatherapi.com"
#else
let weatherAPIHostUrl: String = "https://api.weatherapi.com"
#endif
struct urlList {
    let addressSearchWebLink = "/api/addressSearchWebView.html"
}
