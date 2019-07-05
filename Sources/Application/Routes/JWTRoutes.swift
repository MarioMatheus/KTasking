//
//  JWTRoutes.swift
//  Application
//
//  Created by Mario Matheus on 28/06/19.
//

import Foundation
import KituraContracts
import SwiftJWT
import LoggerAPI
import Cryptor


fileprivate let usersRoute = Routes.user.rawValue


func initializeJWTRoutes(app: App) {
    app.router.post("\(usersRoute)/login", handler: login)
    app.router.post("\(usersRoute)/register", handler: register)
    
    Log.info("Login routes initialized")
}


fileprivate func login(userCredentials: UserCredentials, completion: @escaping(TokenResponse?, RequestError?) -> Void) {
    let params = UserParams(username: userCredentials.username)
    Worker.queue.execute {
        User.findAll(matching: params) { (users, error) in
            if let users = users, users.count > 0 {
                completion(nil, .ok)
            } else {
                if let userPassword = users?.first?.password, let encrytedPassword = encryptPassword(password: userCredentials.password), encrytedPassword == userPassword {
                    sendToken(by: userCredentials, statusCode: nil, completion)
                } else {
                    completion(nil, .unauthorized)
                }
            }
        }
    }
}


fileprivate func register(userCredentials: UserCredentials, completion: @escaping(TokenResponse?, RequestError?) -> Void) {
    let params = UserParams(username: userCredentials.username)
    Worker.queue.execute {
        User.findAll(matching: params) { (users, error) in
            if let users = users, users.count > 0 {
                completion(nil, .ok)
            } else {
                storeUser(with: userCredentials, completion)
            }
        }
    }
}


fileprivate func sendToken(by userCredentials: UserCredentials, statusCode: RequestError?, _ completion: @escaping(TokenResponse?, RequestError?) -> Void) {
    do {
        let claims = ClaimsStandardJWT(iss: App.jwtKey, sub: userCredentials.username, exp: Date(timeIntervalSinceNow: 3600))
        var jwt = JWT(claims: claims)
        let token = try jwt.sign(using: App.jwtSigner)
        completion(TokenResponse(token: token), statusCode)
    } catch _ {
        completion(nil, .internalServerError)
    }
}


fileprivate func storeUser(with userCredentials: UserCredentials,_ completion: @escaping(TokenResponse?, RequestError?) -> Void) {
    guard let encryptedPassword = encryptPassword(password: userCredentials.password) else {
        return completion(nil, .internalServerError)
    }
    let credentials = UserCredentials(username: userCredentials.username, password: encryptedPassword)
    let user = User(userCredentials: credentials)
    user.save { (_, error) in
        if let _ = error {
            completion(nil, .ormQueryError)
        } else {
            sendToken(by: userCredentials, statusCode: .created, completion)
        }
    }
}


fileprivate func encryptPassword(password: String) -> String? {
    let key = CryptoUtils.byteArray(fromHex: "kitura-cryptor-test-key")
    let data : [UInt8] = CryptoUtils.byteArray(fromHex: password)
    
    if let hmac = HMAC(using: HMAC.Algorithm.sha256, key: key).update(byteArray: data)?.final() {
        return CryptoUtils.hexString(from: hmac)
    }
    
    return nil
}


extension App {

    static let jwtKey = "kitura-jwt-test-key"
    static let jwtSigner = JWTSigner.hs256(key: Data(jwtKey.utf8))
    static let jwtVerifier = JWTVerifier.hs256(key: Data(jwtKey.utf8))

}
