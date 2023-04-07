//
//  RLMChildInfo.swift
//  TakeCare
//
//  Created by Lim on 2019/11/15.
//Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation
import RealmSwift
import SQLite

class RLMChildInfo: Object {
    @objc dynamic var idx: Int       = 0
    @objc dynamic var name: String   = ""
    @objc dynamic var height: Double = 0.0
    @objc dynamic var weight: Double = 0.0
    @objc dynamic var sex: Int       = 0
    @objc dynamic var mainFlag: Bool = false
    @objc dynamic var birthday: Date = Date()

    override static func primaryKey() -> String? {
       return "idx"
    }

    func autoIncrementID() -> Int {
       return (try! Realm().objects(RLMChildInfo.self).max(ofProperty: "idx") as Int? ?? 0) + 1
    }
}

enum ScheduleType: Int {
    case vcn    = 0
    case event  = 1
    case notice = 2
}

class RLMChildVCNScheduleInfo: Object {
    @objc dynamic var idx: Int        = 0      // 스케쥴인덱스
    @objc dynamic var childIdx: Int   = 0      // 아이인덱스
    @objc dynamic var vcnIdx: Int     = -1     // 예방접종인덱스
    @objc dynamic var startDate: Date = Date() // 시작일자
    @objc dynamic var endDate: Date   = Date() // 종료일자
    @objc dynamic var title: String   = ""     // 일정 제목
    @objc dynamic var message: String = ""     // 일정 내용
    @objc dynamic var vcnCD: String   = ""     // 예방접종코드
    @objc dynamic var type: Int       = 0      // 스케쥴 구분
    @objc dynamic var checkFlag: Bool = false  // 스케쥴 확인
    
    override static func primaryKey() -> String? {
       return "idx"
    }

    func autoIncrementID() -> Int {
       return (try! Realm().objects(RLMChildVCNScheduleInfo.self).max(ofProperty: "idx") as Int? ?? 0) + 1
    }
}

func scheduleAllDelete() {
    // 확인하지 않는 일정에 대해서 지운다..
    let realm = try! Realm()
    let vcnScheduleData = realm.objects(RLMChildVCNScheduleInfo.self).filter("checkFlag = false")
    try! realm.write {
        realm.delete(vcnScheduleData)
    }
}

func childAllVcnScheduleUpdate() {
    let realm = try! Realm()
    let childDatas = realm.objects(RLMChildInfo.self)
    if childDatas.count > 0 {
        for data in childDatas {
            childVcnScheduleUpdate(child: data)
        }
    }
}

func childVcnScheduleUpdate(child: RLMChildInfo) {
    let realm = try! Realm()
    if let scheduleInfoArray = SQLiteManager.shared.selectAllQuery(tableName: "VCN_SCHEDULE_INFO"), scheduleInfoArray.count > 0 {
        // 등록된 예방접종 데이터가 있다면..
        DLog("scheduleInfoArray :: \(scheduleInfoArray)")
        for arrayData in scheduleInfoArray {
            if let schedule = arrayData as? Row {
                let vcnIdx = try! schedule.get(Expression<Int>("IDX"))
                let sMonth = try! schedule.get(Expression<String>("SMONTH"))
                let eMonth = try! schedule.get(Expression<String>("EMONTH"))
                let title = try! schedule.get(Expression<String>("TITLE"))
                let message = try! schedule.get(Expression<String?>("MESSAGE"))
                let vcnCD = try! schedule.get(Expression<String>("VCNCD"))
                
                if let sdate = child.birthday.afterMonthDate(month: Int(sMonth)!), let edate = sdate.afterMonthDate(month: Int(eMonth)!) {
                    let vcnScheduleData = realm.objects(RLMChildVCNScheduleInfo.self).filter("vcnIdx = %d AND childIdx = %d", vcnIdx, child.idx)
                    if vcnScheduleData.count > 0 {
                        // update
                        try! realm.write {
                            vcnScheduleData[0].vcnIdx    = vcnIdx
                            vcnScheduleData[0].startDate = sdate
                            vcnScheduleData[0].endDate   = edate
                            vcnScheduleData[0].title     = title
                            vcnScheduleData[0].message   = message ?? ""
                            vcnScheduleData[0].vcnCD     = vcnCD
                        }
                    } else {
                        // insert
                        let vcnData = RLMChildVCNScheduleInfo()
                        vcnData.idx       = vcnData.autoIncrementID()
                        vcnData.childIdx  = child.idx
                        vcnData.vcnIdx    = vcnIdx
                        vcnData.startDate = sdate
                        vcnData.endDate   = edate
                        vcnData.title     = title
                        vcnData.message   = message ?? ""
                        vcnData.vcnCD     = vcnCD
                        vcnData.type      = ScheduleType.vcn.rawValue
                        vcnData.checkFlag = (sdate < Date() ? true : false)
                        try! realm.write {
                            realm.add(vcnData)
                        }
                    }
                }
            }
        }
    }
}
