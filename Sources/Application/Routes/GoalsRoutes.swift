//
//  GoalsRoutes.swift
//  Application
//
//  Created by Mario Matheus on 20/06/19.
//

import Foundation
import LoggerAPI
import Kitura
import SwiftJWT


fileprivate let goalsRoute = Routes.goals.rawValue

func initializeGoalsRoutes(app: App) {
    app.router.get(goalsRoute, handler: getGoals)
    app.router.get(goalsRoute, handler: getGoal)
    app.router.post(goalsRoute, handler: addGoal)
    app.router.put(goalsRoute, handler: updateGoal)
    app.router.delete(goalsRoute, handler: removeGoal)
    
    Log.info("Goals routes initialized")
}


fileprivate func getGoals(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, params: GoalParams?, completion: @escaping ([Goal]?, RequestError?) -> Void) {
    guard let userName = typeSafeJWT.jwt.claims.sub else {
        return completion(nil, .unauthorized)
    }
    let goalParams = UserGoalsParams(user: userName, goalName: params?.name)
    Worker.queue.execute {
        Goal.findAll(matching: goalParams, completion)
    }
}


fileprivate func getGoal(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, id: String, completion: @escaping (Goal?, RequestError?) -> Void) {
    Worker.queue.execute {
        Goal.find(id: id) { (goal, error) in
            if goal?.user == typeSafeJWT.jwt.claims.sub {
                completion(goal, nil)
            } else if error == nil {
                completion(nil, .notFound)
            } else {
                completion(nil, error)
            }
        }
    }
}


fileprivate func addGoal(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, goal: Goal, completion: @escaping (Goal?, RequestError?) -> Void) {
    guard let userName = typeSafeJWT.jwt.claims.sub else {
        return completion(nil, .unauthorized)
    }
    var newGoal = goal
    newGoal.id = UUID().uuidString
    newGoal.createdAt = Date()
    newGoal.user = userName
    
    Worker.queue.execute {
        newGoal.save(completion)
    }
}


fileprivate func updateGoal(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, id: String, goal: Goal , completion: @escaping (Goal?, RequestError?) -> Void) {
    Worker.queue.execute {
        Goal.find(id: id) { (goalFound, error) in
            if goalFound?.user == typeSafeJWT.jwt.claims.sub {
                goal.update(id: id, completion)
            } else if error == nil {
                completion(nil, .notFound)
            } else {
                completion(nil, error)
            }
        }
    }
}


fileprivate func removeGoal(typeSafeJWT: TypeSafeJWT<ClaimsStandardJWT>, id: String, completion: @escaping (RequestError?) -> Void) {
    Worker.queue.execute {
        Goal.find(id: id) { (goal, error) in
            if goal?.user == typeSafeJWT.jwt.claims.sub {
                Goal.delete(id: id, completion)
            } else if error == nil {
                completion(.notFound)
            } else {
                completion(error)
            }
        }
    }
}
