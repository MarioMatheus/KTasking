//
//  Task.swift
//  Application
//
//  Created by Mario Matheus on 20/06/19.
//

import Foundation
import KituraContracts
import SwiftKuery
import SwiftKueryORM


struct Task: Model {
    
    var id: String?
    var createdAt: Date?
    var name: String
    var fromGoal: String
    var date: Date
    var isDone: Bool?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case name = "name"
        case fromGoal = "from_goal"
        case date = "date"
        case isDone = "is_done"
    }
    
    
    private static func parse(tableRow: [String: Any?]) -> Task? {
        guard let id = tableRow["id"] as? String, let createdAt = tableRow["created_at"] as? Double, let name = tableRow["name"] as? String,
        let fromGoal = tableRow["from_goal"] as? String, let date = tableRow["date"] as? Double, let isDone = tableRow["is_done"] as? Bool else {
            return nil
        }
        return Task(id: id, createdAt: Date(timeIntervalSinceReferenceDate: TimeInterval(createdAt)), name: name,
                    fromGoal: fromGoal, date: Date(timeIntervalSinceReferenceDate: TimeInterval(date)), isDone: isDone)
    }
    
    
    static func findUserOwner(id: String, _ completion: @escaping (String?, RequestError?) -> Void) {
        do {
            let taskTable = try Task.getTable()
            let goalTable = try Goal.getTable()
                Persistence.connection?.execute(
                    """
                    Select Goals.user FROM "\(goalTable.nameInQuery)" Goals, "\(taskTable.nameInQuery)" Tasks
                        WHERE \(taskTable.nameInQuery).id = '\(id)'
                        AND \(taskTable.nameInQuery).from_goal = \(goalTable.nameInQuery).id
                    """, onCompletion: { result in
                        if let username = result.asRows?.first?["user"] as? String {
                            completion(username, nil)
                        } else {
                            completion(nil, .ormQueryError)
                        }
                })
        } catch {
            completion(nil, .ormQueryError)
        }
    }
    
    
    static func findAll(from username: String, _ completion: @escaping ([Task]?, RequestError?) -> Void) {
        do {
            let taskTable = try Task.getTable()
            let goalTable = try Goal.getTable()
            Persistence.connection?.execute(
                """
                Select Tasks.* FROM "\(goalTable.nameInQuery)" Goals, "\(taskTable.nameInQuery)" Tasks
                WHERE \(goalTable.nameInQuery).user = '\(username)'
                AND \(taskTable.nameInQuery).from_goal = \(goalTable.nameInQuery).id
                """, onCompletion: { result in
                    guard let rows = result.asRows else {
                        if result.success {
                            return completion([], nil)
                        } else {
                            return completion(nil, .ormQueryError)
                        }
                    }
                    print(rows)
                    completion(rows.compactMap({ Task.parse(tableRow: $0) }), nil)
            })
        } catch {
            print("entrei aki será")
            completion(nil, .ormQueryError)
        }
    }
    
}
