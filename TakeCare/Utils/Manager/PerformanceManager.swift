//
//  PerformanceManager.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/02/17.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation
import Firebase
#if canImport(FirebasePerformance)
import FirebasePerformance
#endif
#if canImport(Sentry)
import Sentry
#endif
class PerformanceManager: NSObject {
    enum TraceNameList: String {
        case none           = "none"
        case googleLogin    = "app_login_google"
        case appleLogin     = "app_login_apple"
        case appleNTP       = "app_clock_ntp_apple"
    }

    enum OperationType: String {
        case trace = "Trace"
        case https = "Https"
    }
#if canImport(FirebasePerformance)
    var trace: Trace? // Firebase Performance 추척
#endif
    var traceStartName: TraceNameList = .none
    var tracOoperation: OperationType = .trace

#if canImport(Sentry)
    var startLoadSpan: Span? // Sentry Performance 추척
    var childSpan: Span?
#endif
    var isUseSentry: Bool = true // Sentry Performance 사용 유무.

    // MARK: - Sentry Performance
    private func startTransaction() {
        guard isUseSentry else { return }
#if canImport(Sentry)
        if startLoadSpan != nil {
            startLoadSpan?.finish()
            startLoadSpan = nil
        }
        startLoadSpan = SentrySDK.startTransaction(name: traceStartName.rawValue, operation: tracOoperation.rawValue)
#endif
    }

    private func stopTransaction() {
        guard isUseSentry else { return }
#if canImport(Sentry)
        if startLoadSpan != nil {
            if childSpan != nil {
                childSpan?.finish()
                childSpan = nil
            }
            startLoadSpan?.finish()
            startLoadSpan = nil
        }
#endif
    }

    private func startChildTransaction(eventName: String, byValue: Int64) {
        guard isUseSentry else { return }
#if canImport(Sentry)
        if startLoadSpan != nil {
            if childSpan != nil {
                childSpan?.finish()
                childSpan = nil
            }
            childSpan = startLoadSpan?.startChild(operation: eventName, description: "value : \(byValue)")
        }
#endif
    }

    private func setValue(value: String, attribute: String) {
        guard isUseSentry else { return }
#if canImport(Sentry)
        if childSpan != nil {
            childSpan?.setExtra(value: value, key: attribute)
        }
#endif
    }

    // MARK: - Google Firebase Performance
    func startTrace(startTraceName: TraceNameList, isUseSentry useSentry: Bool = false) {
        traceStartName = startTraceName
#if canImport(FirebasePerformance)
        if trace != nil {
            trace?.stop()
            trace = nil
        }
        trace = Performance.startTrace(name: traceStartName.rawValue)
#endif
        isUseSentry = useSentry
        startTransaction()
    }

    func stopTrace() {
#if canImport(FirebasePerformance)
        if trace != nil {
            trace?.stop()
            trace = nil
        }
#endif
        stopTransaction()
    }

    func traceIncrementMetric(eventName: String, byValue: Int64 = 1) {
#if canImport(FirebasePerformance)
        if trace != nil {
            trace?.incrementMetric(eventName, by: byValue)
        }
#endif
        startChildTransaction(eventName: eventName, byValue: byValue)
    }

    // Google에서 개인을 개인적으로 식별하는 정보가 포함되어서는 안됩니다.
    func traceSetValue(value: String, attribute: String) {
#if canImport(FirebasePerformance)
        if trace != nil {
            trace?.setValue(value, forAttribute: attribute)
        }
#endif
        setValue(value: value, attribute: attribute)
    }
}
