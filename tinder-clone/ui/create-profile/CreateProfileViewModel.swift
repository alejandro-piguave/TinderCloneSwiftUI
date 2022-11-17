//
//  CreateProfileViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn
import SwiftUI


struct ProfileData{
    let name: String
    let birthDate: Date
    let bio: String
    let isMale: Bool
    let orientation: Orientation
    let pictures: [UIImage]
}

class CreateProfileViewModel: NSObject, ObservableObject {
    @Published private (set) var signUpError: String? = nil
    @Published private (set) var isLoading: Bool = false
    @Published private (set) var isSignUpComplete: Bool = false
    
    private let firestoreRepository: FirestoreRepository = FirestoreRepository.shared
    private let storageRepository: StorageRepository = StorageRepository.shared
    
    func signUp(profileData: ProfileData, controller: UIViewController) {
        self.isLoading = true
        Task{
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                publishError(message: "Default Firebase app does not exist.")
                return
            }

            // Create Google Sign In configuration object.
            let configuration = GIDConfiguration(clientID: clientID)

            do{
                // Start the sign in flow!
                let user = try await signInWithGoogle(with: configuration, presenting: controller)

                guard let userEmail = user.profile?.email else {
                    publishError(message: "Empty e-mail address")
                    return
                }
                guard try await isNewUser(email: userEmail) else {
                    publishError(message: "User already exists.")
                    return
                }

                guard let idToken = user.authentication.idToken else {
                    publishError(message: "No ID token found.")
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)

                try await Auth.auth().signIn(with: credential)
                //Successfully logged in

                let fileNames = try await storageRepository.uploadUserPictures(profileData.pictures)

                try await firestoreRepository.createUserProfile(name: profileData.name, birthDate: profileData.birthDate, bio: profileData.bio, isMale: profileData.isMale, orientation: profileData.orientation, pictures: fileNames)

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isSignUpComplete = true
                }
                }catch{
                publishError(message: error.localizedDescription)
                return
            }
        }
    }

    private func publishError(message: String) {
        DispatchQueue.main.async {
            self.signUpError = message
            self.isLoading = false
        }
    }
    private func isNewUser(email: String) async throws-> Bool{
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
