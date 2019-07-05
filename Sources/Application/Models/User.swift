//
//  User.swift
//  Application
//
//  Created by Mario Matheus on 01/07/19.
//

import Foundation
import KituraContracts
import SwiftKuery
import SwiftKueryORM


struct User: Model {
    
    var username: String
    var password: String?
    
    static var idColumnName = "username"
    static var idColumnType = String.self
    
    init(userCredentials: UserCredentials) {
        self.username = userCredentials.username
        self.password = userCredentials.password
    }
    
}

struct UserParams: QueryParams {
    
    var username: String
    
}
