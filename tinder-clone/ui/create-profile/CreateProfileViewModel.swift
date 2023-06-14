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


class CreateProfileViewModel: NSObject, ObservableObject {
    @Published private (set) var signUpError: String? = nil
    @Published private (set) var isLoading: Bool = false
    @Published private (set) var isSignUpComplete: Bool = false
    
    private let profileRepository = ProfileRepository.shared
    
    func signUp(profileData: CreateProfileModel, controller: UIViewController) {
        self.isLoading = true
        Task{
            do{
                try await profileRepository.signUp(controller: controller, from: profileData)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isSignUpComplete = true
                }
                
            }catch{
                DispatchQueue.main.async {
                    self.signUpError = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
