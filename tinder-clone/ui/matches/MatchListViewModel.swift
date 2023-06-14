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
    @Published private (set) var error: String? = nil
    @Published private (set) var isFirstFetching: Bool = true

    private let matchRepository = MatchRepository.shared
    
    func fetchMatches(){
        self.isLoading = true
        self.error = nil
        Task{
            do {
                let matchModels = try await matchRepository.getMatches()
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
