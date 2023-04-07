//
//  CareModel.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/12/15.
//  Copyright © 2021 Apps Studio. All rights reserved.
//

import Foundation

final class ForecastDayModel: Decodable {
    var date: String = ""
    var date_epoch: Int = 0
    var day: DayWeatherModel?
    var astro: AstroModel?
    var hour: [HourWeatherModel] = []

    private enum CodingKeys: String, CodingKey {
        case date
        case date_epoch
        case day
        case astro
        case hour
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        date       = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        date_epoch = try container.decodeIfPresent(Int.self, forKey: .date_epoch) ?? 0
        day        = try container.decodeIfPresent(DayWeatherModel.self, forKey: .day)
        astro      = try container.decodeIfPresent(AstroModel.self, forKey: .astro)
        hour       = try container.decodeIfPresent([HourWeatherModel].self, forKey: .hour) ?? []
    }
}

final class DayWeatherModel: Decodable {
    var maxtemp_c: Double         = 0
    var maxtemp_f: Double         = 0
    var mintemp_c: Double         = 0
    var mintemp_f: Double         = 0
    var avgtemp_c: Double         = 0
    var avgtemp_f: Double         = 0
    var maxwind_mph: Double       = 0
    var maxwind_kph: Double       = 0
    var totalprecip_mm: Double    = 0
    var totalprecip_in: Double    = 0
    var avgvis_km: Double         = 0
    var avgvis_miles: Double      = 0
    var avghumidity: Int          = 0
    var daily_will_it_rain: Int   = 0
    var daily_chance_of_rain: Int = 0
    var daily_will_it_snow: Int   = 0
    var daily_chance_of_snow: Int = 0
    var condition: ConditionModel?
    var uv: Double                = 0

    private enum CodingKeys: String, CodingKey {
        case maxtemp_c
        case maxtemp_f
        case mintemp_c
        case mintemp_f
        case avgtemp_c
        case avgtemp_f
        case maxwind_mph
        case maxwind_kph
        case totalprecip_mm
        case totalprecip_in
        case avgvis_km
        case avgvis_miles
        case avghumidity
        case daily_will_it_rain
        case daily_chance_of_rain
        case daily_will_it_snow
        case daily_chance_of_snow
        case condition
        case uv
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        maxtemp_c            = try container.decodeIfPresent(Double.self, forKey: .maxtemp_c) ?? 0
        maxtemp_f            = try container.decodeIfPresent(Double.self, forKey: .maxtemp_f) ?? 0
        mintemp_c            = try container.decodeIfPresent(Double.self, forKey: .mintemp_c) ?? 0
        mintemp_f            = try container.decodeIfPresent(Double.self, forKey: .mintemp_f) ?? 0
        avgtemp_c            = try container.decodeIfPresent(Double.self, forKey: .avgtemp_c) ?? 0
        avgtemp_f            = try container.decodeIfPresent(Double.self, forKey: .avgtemp_f) ?? 0
        maxwind_mph          = try container.decodeIfPresent(Double.self, forKey: .maxwind_mph) ?? 0
        maxwind_kph          = try container.decodeIfPresent(Double.self, forKey: .maxwind_kph) ?? 0
        totalprecip_mm       = try container.decodeIfPresent(Double.self, forKey: .totalprecip_mm) ?? 0
        totalprecip_in       = try container.decodeIfPresent(Double.self, forKey: .totalprecip_in) ?? 0
        avgvis_km            = try container.decodeIfPresent(Double.self, forKey: .avgvis_km) ?? 0
        avgvis_miles         = try container.decodeIfPresent(Double.self, forKey: .avgvis_miles) ?? 0
        avghumidity          = try container.decodeIfPresent(Int.self, forKey: .avghumidity) ?? 0
        daily_will_it_rain   = try container.decodeIfPresent(Int.self, forKey: .daily_will_it_rain) ?? 0
        daily_chance_of_rain = try container.decodeIfPresent(Int.self, forKey: .daily_chance_of_rain) ?? 0
        daily_will_it_snow   = try container.decodeIfPresent(Int.self, forKey: .daily_will_it_snow) ?? 0
        daily_chance_of_snow = try container.decodeIfPresent(Int.self, forKey: .daily_chance_of_snow) ?? 0
        condition            = try container.decodeIfPresent(ConditionModel.self, forKey: .condition)
        uv                   = try container.decodeIfPresent(Double.self, forKey: .uv) ?? 0
    }
}

class CurrentWeatherModel: Decodable {
    var last_updated_epoch: Int = 0 // Time as epoch
    var last_updated: String    = "" // Date and time
    var temp_c: Double          = 0 // Temperature in celsius
    var temp_f: Double          = 0 // Temperature in fahrenheit
    var is_day: Int             = 0 // 1 = Yes 0 = No, Whether to show day condition icon or night icon
    var condition: ConditionModel?
    var wind_mph: Double        = 0 // Maximum wind speed in miles per hour
    var wind_kph: Double        = 0 // Maximum wind speed in kilometer per hour
    var wind_degree: Int        = 0 // Wind direction in degrees
    var wind_dir: String        = "" // Wind direction as 16 point compass. e.g.: NSW
    var pressure_mb: Double     = 0 // Pressure in millibars
    var pressure_in: Double     = 0 // Pressure in inches
    var precip_mm: Double       = 0 // Precipitation amount in millimeters
    var precip_in: Double       = 0 // Precipitation amount in inches
    var humidity: Int           = 0 // Humidity as percentage
    var cloud: Int              = 0 // Cloud cover as percentage
    var feelslike_c: Double     = 0 // Feels like temperature as celcius
    var feelslike_f: Double     = 0 // Feels like temperature as fahrenheit
    var vis_km: Double          = 0 // Visibility in kilometer
    var vis_miles: Double       = 0 // Visibility in miles
    var uv: Double              = 0 // UV Index
    var gust_mph: Double        = 0 // Wind gust in miles per hour
    var gust_kph: Double        = 0 // Wind gust in kilometer per hour
    var air_quality: AirQualityModel?

    private enum CodingKeys: String, CodingKey {
        case last_updated_epoch
        case last_updated
        case temp_c
        case temp_f
        case is_day
        case condition
        case wind_mph
        case wind_kph
        case wind_degree
        case wind_dir
        case pressure_mb
        case pressure_in
        case precip_mm
        case precip_in
        case humidity
        case cloud
        case feelslike_c
        case feelslike_f
        case vis_km
        case vis_miles
        case uv
        case gust_mph
        case gust_kph
        case air_quality
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        last_updated_epoch = try container.decodeIfPresent(Int.self, forKey: .last_updated_epoch) ?? 0
        last_updated       = try container.decodeIfPresent(String.self, forKey: .last_updated) ?? ""
        temp_c             = try container.decodeIfPresent(Double.self, forKey: .temp_c) ?? 0
        temp_f             = try container.decodeIfPresent(Double.self, forKey: .temp_f) ?? 0
        is_day             = try container.decodeIfPresent(Int.self, forKey: .is_day) ?? 0
        condition          = try container.decodeIfPresent(ConditionModel.self, forKey: .condition)
        wind_mph           = try container.decodeIfPresent(Double.self, forKey: .wind_mph) ?? 0
        wind_kph           = try container.decodeIfPresent(Double.self, forKey: .wind_kph) ?? 0
        wind_degree        = try container.decodeIfPresent(Int.self, forKey: .wind_degree) ?? 0
        wind_dir           = try container.decodeIfPresent(String.self, forKey: .wind_dir) ?? ""
        pressure_mb        = try container.decodeIfPresent(Double.self, forKey: .pressure_mb) ?? 0
        pressure_in        = try container.decodeIfPresent(Double.self, forKey: .pressure_in) ?? 0
        precip_mm          = try container.decodeIfPresent(Double.self, forKey: .precip_mm) ?? 0
        precip_in          = try container.decodeIfPresent(Double.self, forKey: .precip_in) ?? 0
        humidity           = try container.decodeIfPresent(Int.self, forKey: .humidity) ?? 0
        cloud              = try container.decodeIfPresent(Int.self, forKey: .cloud) ?? 0
        feelslike_c        = try container.decodeIfPresent(Double.self, forKey: .feelslike_c) ?? 0
        feelslike_f        = try container.decodeIfPresent(Double.self, forKey: .feelslike_f) ?? 0
        vis_km             = try container.decodeIfPresent(Double.self, forKey: .vis_km) ?? 0
        vis_miles          = try container.decodeIfPresent(Double.self, forKey: .vis_miles) ?? 0
        uv                 = try container.decodeIfPresent(Double.self, forKey: .uv) ?? 0
        gust_mph           = try container.decodeIfPresent(Double.self, forKey: .gust_mph) ?? 0
        gust_kph           = try container.decodeIfPresent(Double.self, forKey: .gust_kph) ?? 0
        air_quality        = try container.decodeIfPresent(AirQualityModel.self, forKey: .air_quality)
    }
}

final class HourWeatherModel: Decodable {
    var time_epoch: Int     = 0
    var time: String        = ""
    var temp_c: Double      = 0
    var temp_f: Double      = 0
    var is_day: Int         = 0
    var condition: ConditionModel?
    var wind_mph: Double    = 0
    var wind_kph: Double    = 0
    var wind_degree: Int    = 0
    var wind_dir: String    = ""
    var pressure_mb: Double = 0
    var pressure_in: Double = 0
    var precip_mm: Double   = 0
    var precip_in: Double   = 0
    var humidity: Int       = 0
    var cloud: Int          = 0
    var feelslike_c: Double = 0
    var feelslike_f: Double = 0
    var windchill_c: Double = 0
    var windchill_f: Double = 0
    var heatindex_c: Double = 0
    var heatindex_f: Double = 0
    var dewpoint_c: Double  = 0
    var dewpoint_f: Double  = 0
    var will_it_rain: Int   = 0 // 1 = Yes 0 = No, Will it will rain or not
    var chance_of_rain: Int = 0 // Chance of rain as percentage
    var will_it_snow: Int   = 0 // 1 = Yes 0 = No, Will it snow or not
    var chance_of_snow: Int = 0 // Chance of snow as percentage
    var vis_km: Double      = 0
    var vis_miles: Double   = 0
    var gust_mph: Double    = 0
    var gust_kph: Double    = 0
    var uv: Double          = 0

    private enum CodingKeys: String, CodingKey {
        case time_epoch
        case time
        case temp_c
        case temp_f
        case is_day
        case condition
        case wind_mph
        case wind_kph
        case wind_degree
        case wind_dir
        case pressure_mb
        case pressure_in
        case precip_mm
        case precip_in
        case humidity
        case cloud
        case feelslike_c
        case feelslike_f
        case windchill_c
        case windchill_f
        case heatindex_c
        case heatindex_f
        case dewpoint_c
        case dewpoint_f
        case will_it_rain
        case chance_of_rain
        case will_it_snow
        case chance_of_snow
        case vis_km
        case vis_miles
        case gust_mph
        case gust_kph
        case uv
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        time_epoch     = try container.decodeIfPresent(Int.self, forKey: .time_epoch) ?? 0
        time           = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
        temp_c         = try container.decodeIfPresent(Double.self, forKey: .temp_c) ?? 0
        temp_f         = try container.decodeIfPresent(Double.self, forKey: .temp_f) ?? 0
        is_day         = try container.decodeIfPresent(Int.self, forKey: .is_day) ?? 0
        condition      = try container.decodeIfPresent(ConditionModel.self, forKey: .condition)
        wind_mph       = try container.decodeIfPresent(Double.self, forKey: .wind_mph) ?? 0
        wind_kph       = try container.decodeIfPresent(Double.self, forKey: .wind_kph) ?? 0
        wind_degree    = try container.decodeIfPresent(Int.self, forKey: .wind_degree) ?? 0
        wind_dir       = try container.decodeIfPresent(String.self, forKey: .wind_dir) ?? ""
        pressure_mb    = try container.decodeIfPresent(Double.self, forKey: .pressure_mb) ?? 0
        pressure_in    = try container.decodeIfPresent(Double.self, forKey: .pressure_in) ?? 0
        precip_mm      = try container.decodeIfPresent(Double.self, forKey: .precip_mm) ?? 0
        precip_in      = try container.decodeIfPresent(Double.self, forKey: .precip_in) ?? 0
        humidity       = try container.decodeIfPresent(Int.self, forKey: .humidity) ?? 0
        cloud          = try container.decodeIfPresent(Int.self, forKey: .cloud) ?? 0
        feelslike_c    = try container.decodeIfPresent(Double.self, forKey: .feelslike_c) ?? 0
        feelslike_f    = try container.decodeIfPresent(Double.self, forKey: .feelslike_f) ?? 0
        windchill_c    = try container.decodeIfPresent(Double.self, forKey: .windchill_c) ?? 0
        windchill_f    = try container.decodeIfPresent(Double.self, forKey: .windchill_f) ?? 0
        heatindex_c    = try container.decodeIfPresent(Double.self, forKey: .heatindex_c) ?? 0
        heatindex_f    = try container.decodeIfPresent(Double.self, forKey: .heatindex_f) ?? 0
        dewpoint_c     = try container.decodeIfPresent(Double.self, forKey: .dewpoint_c) ?? 0
        dewpoint_f     = try container.decodeIfPresent(Double.self, forKey: .dewpoint_f) ?? 0
        will_it_rain   = try container.decodeIfPresent(Int.self, forKey: .will_it_rain) ?? 0
        chance_of_rain = try container.decodeIfPresent(Int.self, forKey: .chance_of_rain) ?? 0
        will_it_snow   = try container.decodeIfPresent(Int.self, forKey: .will_it_snow) ?? 0
        chance_of_snow = try container.decodeIfPresent(Int.self, forKey: .chance_of_snow) ?? 0
        vis_km         = try container.decodeIfPresent(Double.self, forKey: .vis_km) ?? 0
        vis_miles      = try container.decodeIfPresent(Double.self, forKey: .vis_miles) ?? 0
        gust_mph       = try container.decodeIfPresent(Double.self, forKey: .gust_mph) ?? 0
        gust_kph       = try container.decodeIfPresent(Double.self, forKey: .gust_kph) ?? 0
        uv             = try container.decodeIfPresent(Double.self, forKey: .uv) ?? 0
    }
}

class ConditionModel: Decodable {
    var text: String = ""
    var icon: String = ""
    var code: Int = 0

    private enum CodingKeys: String, CodingKey {
        case text, icon, code
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? ""
        code = try container.decodeIfPresent(Int.self, forKey: .code) ?? 0
    }
}

class AstroModel: Decodable {
    var sunrise: String           = ""
    var sunset: String            = ""
    var moonrise: String          = ""
    var moonset: String           = ""
    var moon_phase: String        = ""
    var moon_illumination: String = ""

    private enum CodingKeys: String, CodingKey {
        case sunrise, sunset, moonrise, moonset, moon_phase, moon_illumination
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        sunrise           = try container.decodeIfPresent(String.self, forKey: .sunrise) ?? ""
        sunset            = try container.decodeIfPresent(String.self, forKey: .sunset) ?? ""
        moonrise          = try container.decodeIfPresent(String.self, forKey: .moonrise) ?? ""
        moonset           = try container.decodeIfPresent(String.self, forKey: .moonset) ?? ""
        moon_phase        = try container.decodeIfPresent(String.self, forKey: .moon_phase) ?? ""
        if let valueDouble = try? container.decodeIfPresent(Double.self, forKey: .moon_illumination) {
            moon_illumination = "\(valueDouble ?? 0)"
        } else if let valueString = try? container.decodeIfPresent(String.self, forKey: .moon_illumination) {
            moon_illumination = valueString ?? ""
        }
    }
}

class AirQualityModel: Decodable {
    var co: Double = 0
    var no2: Double = 0
    var o3: Double = 0
    var so2: Double = 0
    var pm2_5: Double = 0
    var pm10: Double = 0
    var us_epa_index: Int = 0 // US - EPA standard.
    var gb_defra_index: Int = 0 // UK Defra Index (See table below)

    private enum CodingKeys: String, CodingKey {
        case co, no2, o3, so2, pm2_5, pm10
        case us_epa_index = "us-epa-index"
        case gb_defra_index = "gb-defra-index"
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        co             = try container.decodeIfPresent(Double.self, forKey: .co) ?? 0
        no2            = try container.decodeIfPresent(Double.self, forKey: .no2) ?? 0
        o3             = try container.decodeIfPresent(Double.self, forKey: .o3) ?? 0
        so2            = try container.decodeIfPresent(Double.self, forKey: .so2) ?? 0
        pm2_5          = try container.decodeIfPresent(Double.self, forKey: .pm2_5) ?? 0
        pm10           = try container.decodeIfPresent(Double.self, forKey: .pm10) ?? 0
        us_epa_index   = try container.decodeIfPresent(Int.self, forKey: .us_epa_index) ?? 0
        gb_defra_index = try container.decodeIfPresent(Int.self, forKey: .gb_defra_index) ?? 0
    }
}
