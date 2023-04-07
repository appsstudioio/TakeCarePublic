//
//  WeatherTimeViewModel.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2022/01/21.
//  Copyright © 2022 Apps Studio. All rights reserved.
//

import Foundation

final class WeatherTimeViewModel {
    var forecastData: [ForecastDayModel] = []

    // MARK: - variables
    var onUpdate: () -> Void = {}

    // MARK: - functions
    func setHourData(datas: [ForecastDayModel]) {
        forecastData.removeAll()
        forecastData = datas
        for index in 0..<datas.count {
            if datas[index].hour.count > 0 {
                let hour = datas[index].hour.filter({ $0.time.toDate(format: "yyyy-MM-dd HH:mm")! > Date() })
                forecastData[index].hour = hour
            }
        }
        onUpdate()
    }


}

// MARK: - extensions

