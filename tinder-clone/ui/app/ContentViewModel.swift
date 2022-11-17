//
//  GoogleSignInViewModel.swift
//  Tinder 2
//
//  Created by Alejandro Piguave on 1/1/22.
//

import Foundation

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn
import SwiftUI

enum AuthState{
    case loading, logged, unlogged
}

class ContentViewModel: NSObject, ObservableObject {
    @Published var authState: AuthState = .loading

    func updateAuthState(){
        if(Auth.auth().currentUser != nil){
            self.authState = .logged
        } else {
            self.authState = .unlogged
        }
    }
    
    func signOut(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.authState = .unlogged
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}
