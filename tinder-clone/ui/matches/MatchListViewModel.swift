//
//  MatchListViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 17/11/22.
//

import Foundation

class MatchListViewModel: NSObject, ObservableObject {
    @Published var matchModels: [MatchModel] = []
    
    @Published private (set) var isLoading: Bool = true
    @Published private (set) var error: String = ""
    @Published private (set) var isFirstFetching: Bool = true
    
    private let firestoreRepository: FirestoreRepository = FirestoreRepository.shared
    private let storageRepository: StorageRepository = StorageRepository.shared
    
    func fetchMatches(){
        self.isLoading = true
        Task{
            do {
                let matchedUsers = try await firestoreRepository.getMatchedUsers()
                
                let matchedUsersMap = matchedUsers.reduce(into: [String: String](),  {
                    $0[$1.profile.id!] = $1.profile.pictures.first!
                })
                
                let picturesMap = try await storageRepository.getPictureFromUsers(usersMap: matchedUsersMap)
                
                let matchModels: [MatchModel] = picturesMap.map({key, value in
                    let matchProfile: MatchProfile = matchedUsers.first(where: {$0.profile.id == key})!
                    
                    let matchModel = MatchModel(id: matchProfile.id, timestamp: matchProfile.timestamp, userId: matchProfile.profile.id!, name: matchProfile.profile.name, birthDate: matchProfile.profile.birthDate, picture: value, lastMessage: nil)
                    return matchModel
                })
                DispatchQueue.main.async {
                    self.isFirstFetching = false
                    self.matchModels = matchModels
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
