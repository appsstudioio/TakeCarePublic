//
//  Networks+WeatherAPI.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/12/17.
//  Copyright © 2021 Apps Studio. All rights reserved.
//

import Foundation
import Moya

// NOTE: Weather API Documents
// https://www.weatherapi.com/docs/
enum WeatherAPI {
    case currentWeather(query: String)
    case forecast(query: String, days: String)
    case history(query: String, days: String, dates: String)
}

// MARK: - TargetType Protocol Implementation
extension WeatherAPI: TargetType {
    var baseURL: URL { URL(string: weatherAPIHostUrl)! }
    var path: String {
        switch self {
        case .currentWeather(_):
            return "/v1/current.json"
        case .forecast(_, _):
            return "/v1/forecast.json"
        case .history(_, _, _):
            return "/v1/history.json"
        }
    }
    var method: Moya.Method {
        switch self {
        case .currentWeather, .forecast, .history:
            return .get
        }
    }
    var task: Task {
        var parameters: [String: Any] = ["key": globalWeatherServiceKey,
                                         "lang": Locale.current.languageCode ?? "ko",
                                         "aqi": "yes",
                                         "alerts": "yes"]
        switch self {
        case let .currentWeather(query):
            parameters["q"] = query
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .forecast(query, days):
            parameters["q"] = query
            parameters["days"] = days
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .history(query, days, dates):
            parameters["q"] = query
            parameters["days"] = days
            // dt or end_dt parameter should be in yyyy-MM-dd format and on or after 1st Jan, 2010 (2010-01-01)
            parameters["days"] = dates
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    var sampleData: Data {
        switch self {
            case .currentWeather(_):
            guard let url = Bundle.main.url(forResource: "currentSampleData", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        case .forecast(_, _):
            guard let url = Bundle.main.url(forResource: "forecastSampleData", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        case .history(_, _, _):
            guard let url = Bundle.main.url(forResource: "historySampleData", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
