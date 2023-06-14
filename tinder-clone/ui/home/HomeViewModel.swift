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
    
    @Published var userProfiles: [ProfileCardModel] = []
    @Published private (set) var lastMatchProfile: ProfileCardModel? = nil

    @Published private (set) var isFirstFetching: Bool = true
    @Published private (set) var error: String? = nil
    @Published private (set) var isLoading: Bool = true

    private let profileCardRepository = ProfileCardRepository.shared
    
    func swipeUser(user: ProfileCardModel, hasLiked: Bool) {
        Task{
            do{
                let isMatch = try await profileCardRepository.swipeUser(swipedUserId: user.userId, hasLiked: hasLiked)
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
    
    func fetchProfiles(){
        self.isLoading = true
        self.error = nil
        Task{
            do {
                
                let profileCards = try await profileCardRepository.getProfiles()

                DispatchQueue.main.async{
                    self.isFirstFetching = false
                    self.userProfiles = profileCards
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
