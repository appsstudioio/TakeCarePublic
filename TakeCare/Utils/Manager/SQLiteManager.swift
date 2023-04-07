//
//  SQLiteManager.swift
//  TakeCare
//
//  Created by Lim on 2019/12/11.
//  Copyright © 2019 Apps Studio. All rights reserved.
//

import Foundation
import SQLite

class SQLiteManager: NSObject {
    var db: Connection? = nil
    
    override init() {
        super.init()
        if let path = Bundle.main.path(forResource: "takecare", ofType: "sqlite3") {
            do {
               db = try Connection(path)
            } catch let error {
                self.sqliteErrorLog(message: error.localizedDescription)
            }
        }
    }
    
    deinit {
        self.db = nil
    }
    
    static let shared: SQLiteManager = {
        var instance = SQLiteManager()
        return instance
    }()
    
    private func sqliteErrorLog(message: String) {
        DLog("=== SQLiteManager :: \(message)")
    }
    
    func selectAllQuery(tableName: String) -> Array<Any>? {
        let tables = Table(tableName)
        if let dbCon = self.db {
            let allArray = Array(try! dbCon.prepare(tables))
            return allArray
        } else {
            return nil
        }
    }
    
    func getVcnInfoMessgae(query: String) -> String? {
        if let dbCon = self.db {
            for row in try! dbCon.prepare(query) {
                return row[3] as? String
            }
        }
        return nil
    }
    
    func getHolidayInfo(query: String) -> (String?, String?) {
        if let dbCon = self.db {
            for row in try! dbCon.prepare(query) {
                return (row[1] as? String, row[2] as? String)
            }
        }
        return (nil, nil)
    }
}
