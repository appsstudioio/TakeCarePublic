//
//  AppConfigData.swift
//  TakeCare
//
//  Created by Lim on 24/07/2019.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation

// Google Firebase Remote Config Model
class AppConfigData: Decodable {
    var verInfo: VersionInfo?
    var fiexedUpdateFlag: Bool      = false
    var fiexedUpdateVersion: String = ""
    var fiexedUpdateMsg: String     = ""

    private enum CodingKeys: String, CodingKey {
        case verInfo, fiexedUpdateFlag, fiexedUpdateVersion, fiexedUpdateMsg
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        verInfo             = try container.decodeIfPresent(VersionInfo.self, forKey: .verInfo)
        fiexedUpdateFlag    = try container.decodeIfPresent(Bool.self, forKey: .fiexedUpdateFlag) ?? false
        fiexedUpdateVersion = try container.decodeIfPresent(String.self, forKey: .fiexedUpdateVersion) ?? ""
        fiexedUpdateMsg     = try container.decodeIfPresent(String.self, forKey: .fiexedUpdateMsg) ?? ""
    }
}

class VersionInfo: Decodable {
    var currentVersion: String = ""
    var appStoreUrl: String    = ""

    private enum CodingKeys: String, CodingKey {
        case currentVersion, appStoreUrl
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        currentVersion = try container.decodeIfPresent(String.self, forKey: .currentVersion) ?? ""
        appStoreUrl    = try container.decodeIfPresent(String.self, forKey: .appStoreUrl) ?? ""
    }
}

class AppInfo: Decodable {
    var locdate: String  = ""
    var dateKind: String = ""
    var dateName: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case locdate, dateKind, dateName
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }

        locdate  = try container.decodeIfPresent(String.self, forKey: .locdate) ?? ""
        dateKind = try container.decodeIfPresent(String.self, forKey: .dateKind) ?? ""
        dateName = try container.decodeIfPresent(String.self, forKey: .dateName) ?? ""
    }
}
