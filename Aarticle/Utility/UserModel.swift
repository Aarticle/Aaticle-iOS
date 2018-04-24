//
//  UserModel.swift
//  Aarticle
//
//  Created by Phyllis Wong on 4/24/18.
//  Copyright © 2018 Phyllis Wong. All rights reserved.
//


import Foundation
import KeychainSwift

struct User: Codable {
    let id: Int
    let username: String
    let password: String
//    let token: String?
    
    static func getStoredUser() -> User {
        let userPersistence = UserPersistence()
        guard let currentUser = userPersistence.getCurrentUser() else {
            fatalError("No Current User Data")
        }
        return currentUser
    }
}


struct UserLoginRegister: Codable {
    let username: String
    let password: String
}


struct UserPersistence {
    
    private let usernameKey: String = "username"
    private let passwordKey: String = "password"
    private let tokenKey: String = "token"
    private let currentUserKey: String = "currentUser"
    
    func setCurrentUser(currentUser: User) {
        let keychain = KeychainSwift()
        guard let currentUserData = try? JSONEncoder().encode(currentUser) else {
            fatalError("no current user")
        }
        keychain.set(currentUserData, forKey: currentUserKey)
        setUserToken(token: currentUser.token!)
    }
    
    func getCurrentUser() -> User? {
        let keychain = KeychainSwift()
        guard let currentUserData = keychain.getData(currentUserKey), let currentUser = try? JSONDecoder().decode(User.self, from: currentUserData) else {
            return nil
        }
        return currentUser
    }
    
    func loginUser(username: String, password: String) {
        let keychain = KeychainSwift()
        keychain.set(username, forKey: usernameKey)
        keychain.set(password, forKey: passwordKey)
    }
    
    func getUserLoginCredentials() -> (username: String, password: String)? {
        let keychain = KeychainSwift()
        guard let username = keychain.get(usernameKey), let password = keychain.get(passwordKey) else {
            return nil
        }
        return (username, password)
    }
    
    func setUserToken(token: String) {
        let keychain = KeychainSwift()
        keychain.set(token, forKey: tokenKey)
    }
    
    func getUserToken() -> String? {
        let keychain = KeychainSwift()
        guard let token = keychain.get(tokenKey) else {
            return nil
        }
        return token
    }
    
    func logoutUser() {
        let keychain = KeychainSwift()
        keychain.delete(usernameKey)
        keychain.delete(passwordKey)
        keychain.delete(tokenKey)
    }
    
    func checkUserLoggedIn(callback: @escaping (Bool) -> ()) {
        
        let networkStack = NetworkStack()
        //        let keychain = KeychainSwift()
        guard let userCredentials = getUserLoginCredentials() else {
            return callback(false)
        }
        
        let userLogin = UserLoginRegister(username: userCredentials.username, password: userCredentials.password)
        
        networkStack.login(a: userLogin) { (result) in
            switch result {
            case .success(let userReturned):
                self.setUserToken(token: userReturned.token!)
                callback(true)
            case .failure(let error):
                
                // FIXME: breaking here with bad credentials
                //                assertionFailure("bad user credentials \(error.localizedDescription)")
                callback(false)
            }
        }
    }
    
}
