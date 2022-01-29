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
    case loading, logged, unlogged, pendingInformation
}

class AuthViewModel: NSObject, ObservableObject {
    private let db = Firestore.firestore()
    private let userId: String? = Auth.auth().currentUser?.uid
    @Published var authState: AuthState = .loading
    @AppStorage("hasCheckedPendingInfo") private var hasCheckedPendingInfo: Bool = false

    func updateAuthState(){
        if(Auth.auth().currentUser != nil && hasCheckedPendingInfo){
            self.authState = .logged
        } else if(Auth.auth().currentUser != nil && !hasCheckedPendingInfo){
            let userId: String = Auth.auth().currentUser!.uid
            db.collection("users").document(userId).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.signIn()
                } else {
                    self.authState = .pendingInformation
                }
            }
        } else {
            self.authState = .unlogged
        }
    }
    
    func signInWithGoogle(controller: UIViewController){
        if authState == .logged {
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: controller) { user, error in

          if let error = error {
              print(error.localizedDescription)
            return
          }

          guard let authentication = user?.authentication, let idToken = authentication.idToken else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

        
        
        Auth.auth().signIn(with: credential){ result, error in
            if let error = error {
                print(error.localizedDescription)
              return
            }
            self.updateAuthState()
        }
        }
    }
    
    func signIn(){
        self.hasCheckedPendingInfo = true
        self.authState = .logged
    }
    
    func signOut(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.hasCheckedPendingInfo = false
            self.authState = .unlogged
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}
