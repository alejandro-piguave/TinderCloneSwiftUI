//
//  LoginViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 26/10/22.
//

import Foundation

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn
import SwiftUI

struct LoginError: Error{
    let message: String
    init(message: String){
        self.message = message
    }
}

class LoginViewModel: NSObject, ObservableObject {
    @Published var loginError: LoginError? = nil

    func signIn(controller: UIViewController) async{
    
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.loginError = LoginError(message: "Default Firebase app does not exist.")
            return
        }

        // Create Google Sign In configuration object.
        let configuration = GIDConfiguration(clientID: clientID)

        do{
            // Start the sign in flow!
            let user = try await signInWithGoogle(with: configuration, presenting: controller)
            
            guard let userEmail = user.profile?.email else {
                self.loginError = LoginError(message: "Empty e-mail address")
                return
            }
            
            if try await isNewUser(email: userEmail) {
                self.loginError = LoginError(message: "User doesn't exist. Please create an account first.")
                return
            }
            
            guard let idToken = user.authentication.idToken else {
                self.loginError = LoginError(message: "No ID token found.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)
            
            try await Auth.auth().signIn(with: credential)
            //Successfully logged in
            
        }catch{
            self.loginError = LoginError(message: error.localizedDescription)
            return
        }
    }
    
    func isNewUser(email: String) async throws-> Bool{
        let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
        return methods.isEmpty
    }
    
    
    func signInWithGoogle(with configuration: GIDConfiguration, presenting controller: UIViewController) async throws -> GIDGoogleUser{
        return try await withCheckedThrowingContinuation{ continuation in
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: controller) { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning: user!)
            }
        }
    }
    
}
