//
//  UserCredentials.swift
//  Application
//
//  Created by Mario Matheus on 28/06/19.
//

import Foundation


struct UserCredentials: Codable {
    
    var username: String
    var password: String
    
}


struct TokenResponse: Codable {
    
    var token: String
    
}
