//
//  Persistence.swift
//  Application
//
//  Created by Mario Matheus on 23/06/19.
//

import Foundation
import SwiftKuery
import SwiftKueryORM
import SwiftKueryPostgreSQL
import LoggerAPI


class Persistence {
    
    private static let pool: SwiftKuery.ConnectionPool = {
        return PostgreSQLConnection.createPool(
            host: ProcessInfo.processInfo.environment["DBHOST"] ?? "localhost",
            port: 5432,
            options: [
                .databaseName("ktasking\(ProcessInfo.processInfo.environment["APP_KT_VERSION"] ?? "")"),
                .userName(ProcessInfo.processInfo.environment["DBUSER"] ?? "postgres"),
                .password(ProcessInfo.processInfo.environment["DBPASSWORD"] ?? "nil"),
            ],
            poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50, timeout: 10000))
    }()
    
    static var connection: Connection? {
        return Database.default?.getConnection()
    }
    
    
    static func setUp() {
        Database.default = Database(pool)
        createUserTable()
        createGoalsTable()
        createTasksTable()
//        try? User.dropTableSync()
//        try? Goal.dropTableSync()
//        try? Task.dropTableSync()
    }
    
    
    private static func createUserTable() {
        do {
            try User.createTableSync()
        } catch let error {
            // Database table already exists
            if let requestError = error as? RequestError, requestError.rawValue == RequestError.ormQueryError.rawValue {
                Log.info("Table \(User.tableName) already exists")
            } else {
                Log.error("Database connection error: " + "\(String(describing: error))")
            }
        }
    }
    
    
    private static func createGoalsTable() {
        do {
            try Goal.createTableSync()
        } catch let error {
            // Database table already exists
            if let requestError = error as? RequestError, requestError.rawValue == RequestError.ormQueryError.rawValue {
                Log.info("Table \(Goal.tableName) already exists")
            } else {
                Log.error("Database connection error: " + "\(String(describing: error))")
            }
        }
    }
    
    
    private static func createTasksTable() {
        do {
            try Task.createTableSync()
        } catch let error {
            // Database table already exists
            if let requestError = error as? RequestError, requestError.rawValue == RequestError.ormQueryError.rawValue {
                Log.info("Table \(Task.tableName) already exists")
            } else {
                Log.error("Database connection error: " + "\(String(describing: error))")
            }
        }
    }
    
}
