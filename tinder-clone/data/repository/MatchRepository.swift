//
//  MatchRepository.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 8/6/23.
//

import Foundation


class MatchRepository {
    
    private init() {}
    
    static let shared = MatchRepository()
    private let storageDataSource: StorageRemoteDataSource = StorageRemoteDataSource.shared
    private let firestoreDataSource: FirestoreRemoteDataSource = FirestoreRemoteDataSource.shared
    
    func getMatches() async throws -> [MatchModel] {
        let matchedUsers = try await firestoreDataSource.getMatchedUsers()
        
        let matchedUsersMap = matchedUsers.reduce(into: [String: String](),  {
            $0[$1.profile.id!] = $1.profile.pictures.first!
        })
        
        let picturesMap = try await storageDataSource.getPictureFromUsers(usersMap: matchedUsersMap)
        
        let matchModels: [MatchModel] = picturesMap.map({key, value in
            let matchProfile: MatchProfile = matchedUsers.first(where: {$0.profile.id == key})!
            
            let matchModel = MatchModel(id: matchProfile.id, timestamp: matchProfile.timestamp, userId: matchProfile.profile.id!, name: matchProfile.profile.name, birthDate: matchProfile.profile.birthDate, picture: value, lastMessage: nil)
            return matchModel
        })
        
        return matchModels
    }
}
