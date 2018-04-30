//
//  Register+Handlers.swift
//  Aarticle
//
//  Created by Phyllis Wong on 4/24/18.
//  Copyright © 2018 Phyllis Wong. All rights reserved.
//

import Foundation

extension LoginController {
    
    /// When a user registers successfully, they are logged into the app
    @objc func handleRegister() {
        
        // Safely unwrap all input values from the user
        guard let username = usernameTextField.text, username.count > 0 else {
            // popup an alert view that user name can't be blank
            self.present(AlertViewController.showUsernameAlert(), animated: true, completion: nil)
            return
        }
        
        guard let password = passwordTextField.text, password.isValidPassword() else {
            // popup an alert view that password is less than 6 characters
            self.present(AlertViewController.showPasswordAlert(), animated: true, completion: nil)
            return
        }
        
        // Set the criteria to register the user, and to log in the user
        let userRegister = UserLoginRegister(username: username, password: password)
        let userLogin = UserLoginRegister(username: username, password: password)
        
        // Ask the API to register the user
        networkStack.register(a: userRegister) { [weak self] (result) in
            
            // Unwrap the ViewController because we are in a closure
            guard let unwrappedSelf = self else { return }
            
            switch result {
                
            // The user was registered into the database
            case .success:
                
                // Auto login the user and navigate to the MyTripsView
                unwrappedSelf.networkStack.login(a: userLogin) { (result) in
                    
                    switch result {
                    case .success(let loggedInUser):
                        print(loggedInUser)
                        unwrappedSelf.userPersistence.setCurrentUser(currentUser: loggedInUser)
                        unwrappedSelf.userPersistence.loginUser(username: userLogin.username, password: userLogin.password)
                        
                        // successfully logged in user
                        unwrappedSelf.dismiss(animated: true, completion: nil)
                        
                    case .failure(let userErrors):
                        DispatchQueue.main.async {
                            unwrappedSelf.present(AlertViewController.showWrongUsernameOrPAsswordAlert(), animated: true, completion: nil)
                        }
                        // Print the erros for debugging
                        print(userErrors.errors)
                    }
                }
                
            case .failure:
                DispatchQueue.main.async {
                    unwrappedSelf.present(AlertViewController.showUserAlreadyRegisteredAlert(), animated: true, completion: nil)
                }
            }
        }
    }
}
