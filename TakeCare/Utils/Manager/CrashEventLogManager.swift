//
//  CrashEventLogManager.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2020/06/29.
//  Copyright © 2020 com. All rights reserved.
//

import Foundation
#if canImport(Sentry)
import Sentry
#endif
import Firebase
import FirebaseCrashlytics

class CrashEventLogManager: NSObject {
    enum LogType {
        case all, sentry, crashlytics
    }
    #if !canImport(Sentry)
    enum SentryLevel: Int {
        case none    = 0
        case debug   = 1
        case info    = 2
        case warning = 3
        case error   = 4
        case fatal   = 5
    }
    #endif

    static let shared: CrashEventLogManager = {
        var instance = CrashEventLogManager()
        return instance
    }()
/*
    func setUserInfo(userData: FanplusUser) {
        guard LoginCheckManager.shared.loginCheck() else { return }
        guard let userIdx = userData.USER_IDX else { return }
        Crashlytics.crashlytics().setUserID("\(userIdx)")

        let user = Sentry.User(userId: "\(userIdx)")
        user.email = userData.EMAIL
        user.username = userData.NICK
        user.data = ["COUNTRY": userData.COUNTRY?.NAME as Any,
                     "BIAS_STAR": userData.BIAS_STAR?.STAR_NAME as Any,
                     "SET_LANG": userData.USER_LANG as Any,
                     "TIME_ZONE": TimeZone.current.identifier as Any,
                     "DEVICE_LOCALE": Locale.current.identifier]
        SentrySDK.setUser(user)
    }
*/

    // MARK: - Event Log Send
    // NOTE: Sentry 및 Firebase Crashlytics 이벤트 로그를 발생하여 보낸다.
    //       Sentry 및 Firebase Crashlytics Log는 message 내용에 따라서 취합된다. message 내용이 다르면 신규 이벤트로 인식하도록 되어 있음
    //       같은 이슈에 대해서는 메세지 내용을 동일하게 구성할것!!
    //       message에는 사용자 Idx 또는 AuthKey 등 값을 포함하지 않는다. Value는 param 또는 tags에 추가할것!
    func logCapture(type: LogType = .all,
                    level: SentryLevel = .error,
                    message: String?,
                    param: [String: Any],
                    tags: [String: Any]? = nil,
                    file: String = #file,
                    funcName: String = #function,
                    line: Int = #line) {
        if type == .sentry {
            self.sentryCaptureLog(level, message: message, param: param, tags: tags, file: file, funcName: funcName, line: line)
        } else {
            if type == .all {
                self.sentryCaptureLog(level, message: message, param: param, tags: tags, file: file, funcName: funcName, line: line)
            }
            self.crashlyticCaptureLog(level, message: message, param: param, tags: tags, file: file, funcName: funcName, line: line)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func crashlyticCaptureLog(_ level: SentryLevel = .error,
                                      message: String?,
                                      param: [String: Any]?,
                                      tags: [String: Any]? = nil,
                                      file: String = #file,
                                      funcName: String = #function,
                                      line: Int = #line) {
        var userInfo: [String: Any] = [:]
        var nameMsg: String = ""

        switch level {
        case .none:
            nameMsg = "none"
        case .info:
            nameMsg = "info"
        case .error:
            nameMsg = "error"
        case .debug:
            nameMsg = "debug"
        case .fatal:
            nameMsg = "fatal"
        case .warning:
            nameMsg = "warning"
        }

        if let params = param, params.count > 0 {
            for (key, value) in params {
                userInfo[key] = value
            }
        }
        if let tag = tags, tag.count > 0 {
            for (key, value) in tag {
                userInfo[key] = value
            }
        }

        nameMsg = "[\(nameMsg)] \(message ?? "nil")"
        let exception = ExceptionModel.init(name: nameMsg, reason: userInfo.toString())
        exception.stackTrace = [
            StackFrame.init(symbol: funcName, file: file, line: line)
        ]
        Crashlytics.crashlytics().record(exceptionModel: exception)
    }

    // swiftlint:enable cyclomatic_complexity
    private func sentryCaptureLog(_ level: SentryLevel = .error,
                                  message: String?,
                                  param: [String: Any]?,
                                  tags: [String: Any]? = nil,
                                  file: String = #file,
                                  funcName: String = #function,
                                  line: Int = #line) {
        #if canImport(Sentry)
        SentrySDK.capture(message: message ?? "nil") { (scope) in
            let fileName: String = (file as NSString).lastPathComponent
            scope.setTag(value: funcName, key: "function_name")
            scope.setTag(value: fileName, key: "source_file")
            scope.setTag(value: "\(line)", key: "Line")
            scope.setTag(value: TimeZone.current.identifier, key: "time_zone")

            if let lists = tags {
                for (key, value) in lists {
                    scope.setTag(value: "\(value)", key: key)
                }
            }
            scope.setLevel(level)
            scope.setExtras(param)
        }
        #endif
    }
}
