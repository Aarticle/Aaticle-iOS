//
//  NetworkingLayer.swift
//  Aarticle
//
//  Created by Phyllis Wong on 4/24/18.
//  Copyright © 2018 Phyllis Wong. All rights reserved.
//

import Foundation
import Moya
import Result
import SwiftyJSON


struct NetworkStack {
    
    private(set) var apiService = MoyaProvider<APIEndPoints>()
    
    struct APIUserError: Error {
        var errors = [String]()
        
        var localizedDescription: String {
            return self.errors.reduce("", { $0 + "\($1)\n"} )
        }
    }
    
    
    // MARK: - User Login
    func register(a user: UserLoginRegister, callback: @escaping (Result<User, APIUserError>) -> ()) {
        /// handles the response data after the networkService has fired and come back with a result
        apiService.request(.registerUser(user)) { (result) in
            
            switch result {
            case .success(let response):
                
                switch response.statusCode {
                case 201:
                    guard let user = try? JSONDecoder().decode(User.self, from: response.data) else {
                        return assertionFailure("JSON data not decodable")
                    }
                    
                    callback(.success(user))
                case 422:
                    let errors = APIUserError(errors: ["Unprocessable entity"])
                    callback(.failure(errors))
                    
                default:
                    let errors = APIUserError(errors: ["Server Error"])
                    callback(.failure(errors))
                }
                
            case .failure(let err):
                let errors = APIUserError(errors: [err.localizedDescription])
                callback(.failure(errors))
            }
        }
    }
    
    func login(a user: UserLoginRegister, callback: @escaping (Result<User, APIUserError>) -> ()) {
        apiService.request(.loginUser(user)) { (result) in
            switch result {
            case .success(let response):
                
                // FIXME: handle 401 (invalid credentials)
                switch response.statusCode {
                case 200:
                    do {
                        let user = try JSONDecoder().decode(User.self, from: response.data)
                        callback(.success(user))
                    } catch {
                        print(error)
                    }
 
                case 201:
                    do {
                        let user = try JSONDecoder().decode(User.self, from: response.data)
                        callback(.success(user))
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                    
                case 401:
                    let errors = APIUserError(errors: ["Invalid Credentials"])
                    callback(.failure(errors))
                default:
                    return assertionFailure("\(response.statusCode)")
                }
                
            case .failure(let err):
                let errors = APIUserError(errors: [err.localizedDescription])
                callback(.failure(errors))
            }
        }
    }
    
}






