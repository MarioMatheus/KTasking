//
//  TasksRoutes.swift
//  Application
//
//  Created by Mario Matheus on 22/06/19.
//

import Foundation
import LoggerAPI
import Kitura
import SwiftJWT


fileprivate let tasksRoute = Routes.tasks.rawValue


func initializeTasksRoutes(app: App) {
    app.router.get(tasksRoute, handler: getTasks)
    app.router.get(tasksRoute, handler: getTask)
    app.router.post(tasksRoute, handler: addTask)
    app.router.put(tasksRoute, handler: updateTask)
    app.router.delete(tasksRoute, handler: removeTask)
    
    Log.info("Tasks routes initialized")
}


fileprivate func getTasks(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, completion: @escaping ([Task]?, RequestError?) -> Void) {
    guard let userName = typeSafeJWT.jwt.claims.sub else {
        return completion(nil, .unauthorized)
    }
    Worker.queue.execute {
        Task.findAll(from: userName, completion)
    }
}


fileprivate func getTask(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, id: String, completion: @escaping (Task?, RequestError?) -> Void) {
    Worker.queue.execute {
        Task.findUserOwner(id: id) { username, error in
            guard let user = username, user == typeSafeJWT.jwt.claims.sub else {
                return completion(nil, .unauthorized)
            }
            Task.find(id: id, completion)
        }
    }
}


fileprivate func addTask(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, task: Task, completion: @escaping (Task?, RequestError?) -> Void) {
    Worker.queue.execute {
        Goal.find(id: task.fromGoal) { (goal, error) in
            if goal?.user == typeSafeJWT.jwt.claims.sub {
                var newTask = task
                newTask.id = UUID().uuidString
                newTask.createdAt = Date()
                newTask.isDone = false
                newTask.save(completion)
            } else {
                completion(nil, .unauthorized)
            }
        }
    }
}


fileprivate func updateTask(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, id: String, task: Task, completion: @escaping (Task?, RequestError?) -> Void) {
    Worker.queue.execute {
        Task.findUserOwner(id: id) { username, error in
            guard let user = username, user == typeSafeJWT.jwt.claims.sub else {
                return completion(nil, .unauthorized)
            }
            task.update(id: id, completion)
        }
    }
}


fileprivate func removeTask(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, id: String, completion: @escaping (RequestError?) -> Void) {
    Worker.queue.execute {
        Task.findUserOwner(id: id) { username, error in
            guard let user = username, user == typeSafeJWT.jwt.claims.sub else {
                return completion(.unauthorized)
            }
            Task.delete(id: id, completion)
        }
    }
}
