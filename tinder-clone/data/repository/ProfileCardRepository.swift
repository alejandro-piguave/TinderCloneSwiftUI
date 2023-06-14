//
//  ProfileCardRepository.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 8/6/23.
//

import Foundation

class ProfileCardRepository {
    
    private init() {}
    
    static let shared = ProfileCardRepository()
    
    private let authDataSource: AuthRemoteDataSource = AuthRemoteDataSource.shared
    private let storageDataSource: StorageRemoteDataSource = StorageRemoteDataSource.shared
    private let firestoreDataSource: FirestoreRemoteDataSource = FirestoreRemoteDataSource.shared
    
    func swipeUser(swipedUserId: String, hasLiked: Bool) async throws -> Bool{
        return try await firestoreDataSource.swipeUser(swipedUserId: swipedUserId, hasLiked: hasLiked)
    }
    
    
    func getProfiles() async throws -> [ProfileCardModel] {
        let userId = try firestoreDataSource.getUserId()
        let currentUser = try await firestoreDataSource.getUserProfile(userId: userId)
        let excludedUserIds = currentUser.liked + currentUser.passed
        let compatibleUsers = try await firestoreDataSource.getCompatibleUsers(isUserMale: currentUser.isMale, userOrientation: currentUser.orientation, excludedUsers: excludedUserIds)
        let usersMap = compatibleUsers.reduce(into: [String: [String]](),  {
            $0[$1.id!] = $1.pictures
        })
        
        let picturesMap = try await storageDataSource.getPicturesFromUsers(usersMap: usersMap)
        
        let userProfiles: [ProfileCardModel] = picturesMap.map({key, value in
            let user: FirestoreUser = compatibleUsers.first(where: {$0.id == key})!
            
            let userProfile = ProfileCardModel(userId: user.id!, name: user.name, age: user.age, pictures: value)
            return userProfile
        })
        
        return userProfiles
    }
}
    
