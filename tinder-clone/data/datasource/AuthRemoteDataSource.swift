//
//  AuthRemoteDataSource.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 8/6/23.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn
import SwiftUI



class AuthRemoteDataSource {
    
    private init() {}
    
    static let shared = AuthRemoteDataSource()

    
    func signIn(controller: UIViewController, authType: AuthTypeModel) async throws {
    
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthErrorModel(message: "Default Firebase app does not exist.")
        }

        // Create Google Sign In configuration object.
        let configuration = GIDConfiguration(clientID: clientID)

        do {
            // Start the sign in flow!
            let user = try await signInWithGoogle(with: configuration, presenting: controller)
            
            guard let userEmail = user.profile?.email else {
                throw AuthErrorModel(message: "Empty e-mail address")
            }
            let isNewUser = try await isNewUser(email: userEmail)
            
            
            switch authType {
            case .newUser where !isNewUser:
                throw AuthErrorModel(message: "User must be new.")
            case .existingUser where isNewUser:
                throw AuthErrorModel(message: "User must already exist.")
            default: break
            }
            
            guard let idToken = user.authentication.idToken else {
                throw AuthErrorModel(message: "No ID token found.")
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)
            
            try await Auth.auth().signIn(with: credential)
            
        }catch{
            throw AuthErrorModel(message: error.localizedDescription)
        }
    }
    
    private func isNewUser(email: String) async throws-> Bool{
        let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
        return methods.isEmpty
    }
    
    
    private func signInWithGoogle(with configuration: GIDConfiguration, presenting controller: UIViewController) async throws -> GIDGoogleUser{
        return try await withCheckedThrowingContinuation{ continuation in
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: controller) { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: user!)
            }
        }
    }
}
