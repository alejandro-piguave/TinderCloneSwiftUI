//
//  HomeViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class HomeViewModel: NSObject, ObservableObject {
    private let db = Firestore.firestore()
    private var userId: String? { Auth.auth().currentUser?.uid }
    private let firestoreRepository: FirestoreRepository = FirestoreRepository.shared
    private let storageRepository: StorageRepository = StorageRepository.shared
    
    @Published var userProfiles: [UserModel] = []
    @Published private (set) var lastMatchProfile: UserModel? = nil

    @Published private (set) var isFirstFetching: Bool = true
    @Published private (set) var error: String = ""
    @Published private (set) var isLoading: Bool = true

    func swipeUser(user: UserModel, hasLiked: Bool) {
        Task{
            do{
                let isMatch = try await firestoreRepository.swipeUser(swipedUserId: user.userId, hasLiked: hasLiked)
                if(isMatch){
                    DispatchQueue.main.async {
                        self.lastMatchProfile = user
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    private func getMatchId(userId1: String, userId2: String) -> String {userId1 > userId2 ? userId1 + userId2 : userId2 + userId1}

    func fetchProfiles(){
        self.isLoading = true
        Task{
            do{
                let currentUser = try await firestoreRepository.getUserProfile()
                let excludedUserIds = currentUser.liked + currentUser.passed
                let compatibleUsers = try await firestoreRepository.getCompatibleUsers(isUserMale: currentUser.isMale, userOrientation: currentUser.orientation, excludedUsers: excludedUserIds)
                let usersMap = compatibleUsers.reduce(into: [String: [String]](),  {
                    $0[$1.id!] = $1.pictures
                })
                
                let picturesMap = try await storageRepository.getPicturesFromUsers(usersMap: usersMap)
                
                let userProfiles: [UserModel] = picturesMap.map({key, value in
                    let user: FirestoreUser = compatibleUsers.first(where: {$0.id == key})!
                    
                    let userProfile = UserModel(userId: user.id!, name: user.name, age: user.age, pictures: value)
                    return userProfile
                })

                DispatchQueue.main.async{
                    self.isFirstFetching = false
                    self.userProfiles = userProfiles
                    self.isLoading = false
                }
            }catch{
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
