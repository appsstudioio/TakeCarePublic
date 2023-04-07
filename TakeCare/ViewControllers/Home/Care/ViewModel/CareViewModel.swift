//
//  CareViewModel.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/12/15.
//  Copyright © 2021 Apps Studio. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

final class CareViewModel {
    enum WeatherAPIResultStatus {
        case success, fail, timeout
    }
    // MARK: - variables
    var currentData: CurrentWeatherModel? = nil
    var forecastData: [ForecastDayModel] = []
    var homeForcastData: [HourWeatherModel] = []
    var scheduleList: Results<RLMChildVCNScheduleInfo>? = nil
    var childInfoList: Results<RLMChildInfo>? = nil
    let realm: Realm = try! Realm()
    var weatherPointLocation: CLLocation? = nil

    var onWeatherUpdate: (WeatherAPIResultStatus) -> Void = { _ in }
    var onUpdate: () -> Void = {}

    // MARK: - functions
    private func setHourData(datas: [ForecastDayModel]) {
        var cnt = 0
        homeForcastData.removeAll()
        for data in datas {
            if data.hour.count > 0 {
                for dataHour in data.hour {
                    if let dateTime = dataHour.time.toDate(format: "yyyy-MM-dd HH:mm") {
                        if dateTime > Date() {
                            if cnt < 5 {
                                homeForcastData.append(dataHour)
                            } else {
                                break
                            }
                            cnt += 1
                        }
                    }
                }
            }
        }
    }

    private func dataToModel(jsonData: [String: Any]?) {
        if let datas = jsonData?["current"] as? [String: Any] {
            if let currentJsonData = try? JSONSerialization.data(withJSONObject: datas) {
                if let decode = try? JSONDecoder().decode(CurrentWeatherModel.self, from: currentJsonData) {
                    self.currentData = decode
                }
            }
        }
        if let forecast = jsonData?["forecast"] as? [String: Any],
           let forecastday = forecast["forecastday"] as? [[String: Any]] {
            if let forecastJsonData = try? JSONSerialization.data(withJSONObject: forecastday) {
                if let decode = try? JSONDecoder().decode([ForecastDayModel].self, from: forecastJsonData) {
                    self.forecastData = decode
                    self.setHourData(datas: decode)
                }
            }
        }
    }

    func getWeatherData(query: WeatherAPI) {
        // 15분 이후에 API 호출한다.
        if let reloadDate = getWeatherReloadDate(), let reloadAfterDate = reloadDate.afterMinuteDate(minute: 15) {
            if reloadAfterDate >= Date() {
                // 15분이 안지났다면... 캐시된 데이터를 가져와서 처리한다..
                if let weatherPointLocation = weatherPointLocation {
                    let pointLocation = CLLocation(latitude: Double(globalLat) ?? 0, longitude: Double(globalLon) ?? 0)
                    let distance = weatherPointLocation.distance(from: pointLocation)
                    // 5Km 이내라면 재요청 하지 않는다.
                    if distance <= 5000 {
                        if let jsonData = TakeCare.getWeatherData() {
                            DLog(jsonData)
                            self.dataToModel(jsonData: jsonData)
                            self.onWeatherUpdate(.success)
                            return
                        }
                    }
                }
            }
        }

        let provider = MoyaProvider<WeatherAPI>()
        provider.request(query) { result in
            switch result {
            case let .success(moyaResponse):
//                let data = moyaResponse.data
                    do {
                        let statusCode = moyaResponse.statusCode
                        let jsonData = try JSONSerialization.jsonObject(with: moyaResponse.data, options: []) as? [String: Any]
                        DLog(jsonData)
                        if statusCode == 200 {
                            saveWeatherData(data: moyaResponse.data)
                            self.dataToModel(jsonData: jsonData)
                        } else {
                            guard let errorData = jsonData?["error"] as? [String: Any] else { return }
                            if let code = errorData["code"] as? Int {
                                NetworksErrorHandling.weatherErrorCode(statusCode: statusCode, errorCode: code)
                            }
                        }
                        self.weatherPointLocation = CLLocation(latitude: Double(globalLat) ?? 0, longitude: Double(globalLon) ?? 0)
                        saveWeatherReloadDate(value: Date())
                        self.onWeatherUpdate(.success)
                    } catch let error {
                        DLog(error.localizedDescription)
                    }
                // do something with the response data or statusCode
            case let .failure(error):
                DLog(error.errorDescription)
                    self.onWeatherUpdate(.fail)
            }
        }
    }

    func updateScheduleData() {
        childInfoList = realm.objects(RLMChildInfo.self).filter("mainFlag == true")
        if childInfoList?.count ?? 0 > 0, let idx = childInfoList?[0].idx {
            let toDate = Date()
            let afterDate = Date().afterMonthDate(month: 1)!
            // 현재 진행중인 일정과 한달 후에 일정을 보여준다.
            scheduleList = realm.objects(RLMChildVCNScheduleInfo.self).filter("childIdx = %d AND ((startDate <= %@ AND endDate >= %@) OR (startDate >= %@ AND startDate <= %@))", idx, toDate, toDate, toDate, afterDate).sorted(byKeyPath: "startDate", ascending: true)
        }
        onUpdate()
    }
}

// MARK: - extensions

