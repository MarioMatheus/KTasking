//
//  Goal.swift
//  Application
//
//  Created by Mario Matheus on 20/06/19.
//

import Foundation
import KituraContracts
import SwiftKueryORM

struct Goal: Model {
    
    var id: String?
    var createdAt: Date?
    var name: String
    var user: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case name = "name"
        case user = "user"
    }
    
}


struct GoalParams: QueryParams {
    
    var name: String?
    
}

struct UserGoalsParams: QueryParams {
    
    var user: String
    var goalName: String?
    
}
