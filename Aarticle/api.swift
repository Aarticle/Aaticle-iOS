//
//  api.swift
//  Aarticle
//
//  Created by Phyllis Wong on 4/24/18.
//  Copyright © 2018 Phyllis Wong. All rights reserved.
//

import Foundation
import Moya

enum APIEndPoints {
    // Users
    case registerUser(UserLoginRegister)
    case loginUser(UserLoginRegister)
    
    // Articles
    case createArticle
    case loadArticle
    
    
    /** if the enum is registerUser or loginUser, return true. otherwise return false */
    var isRegisteringOrLoginging: Bool {
        switch self {
        case .registerUser, .loginUser:
            return true
        default:
            return false
        }
    }
}

// 2: Conforms and implements Target Type (Moya specific protocol)
extension APIEndPoints: TargetType {
    
    // 3: Base URL leads to no end point
    var baseURL: URL { return URL(string: "https://aarticle.herokuapp.com/mob")! }
    
    // 4: get the path to the end point
    var path: String {
        switch self {
            
        // Users
        case .registerUser:
            return "/sign-up"
        case .loginUser:
            return "/login"
            
        // Articles
        case .createArticle:
            return "/article"
        case .loadArticle:
            return "/article"
        }
    }
    
    // 5: HTTP Method
    var method: Moya.Method {
        switch self {
        // Users
        case .registerUser, .loginUser:
            return .post
            
        // Articles
        case .createArticle:
            return .post
        case .loadArticle:
            return .get
        }
    }
    
    // 6: Test the data in Swift
    // MARK: Todo later
    var sampleData: Data {
        return Data()
    }
    
    // 7: Body + params and any attachments
    var task: Task {
        switch self {
            
        // Users
        case .registerUser(let registerUser):
            return .requestJSONEncodable(registerUser)
        case .loginUser(let loginUser):
            return .requestJSONEncodable(loginUser)
            
        // Article
//        case .createArticle(let article):
//            return .requestJSONEncodable(article)
//        case .loadArticle(let article):
//            return .requestJSONEncodable(article)
  
  
        default:
            return .requestPlain
        }
    }
    
    // 8: Include the header as the last bit of the request
    // Sample token for testing: "token": "a0a5304ef3a7ec90deb874a1dd3e4812"
    
    var headers: [String : String]? {
        var defaultHeaders = [String : String]()
        let userPersistence = UserPersistence()
        
        // default header pairs
        if self.isRegisteringOrLoginging {
            
        } else {
            guard let token = userPersistence.getUserToken() else {
                fatalError("no user token")
            }
            
            // Authorization
            defaultHeaders["Authorization"] = "Token token=\(token)"
        }
        return defaultHeaders
    }
}

