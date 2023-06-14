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

class LoginViewModel: NSObject, ObservableObject {
    @Published var loginError: String? = nil
    
    private let profileRepository = ProfileRepository.shared

    func signIn(controller: UIViewController) async{
        do {
            try await profileRepository.signIn(controller: controller)
        }catch{
            DispatchQueue.main.async {
                self.loginError = error.localizedDescription
            }
        }
    }
}
