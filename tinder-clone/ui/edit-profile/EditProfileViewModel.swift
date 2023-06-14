//
//  EditProfileViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation
import UIKit

class EditProfileViewModel: NSObject, ObservableObject {
    
    private let profileRepository: ProfileRepository = ProfileRepository.shared
    
    @Published var userProfile: FirestoreUser? = nil
    @Published var userPictures: [PictureModel] = []
    @Published var isProfileUpdated: Bool = false
    
    @Published private (set) var isLoading: Bool = true
    @Published private (set) var error: String = ""
    
    func fetchProfile() {
        self.isLoading = true
        Task{
            do{
                //Fetch profile information
                let user = try await profileRepository.getUserProfile()
                DispatchQueue.main.async {
                    self.userProfile = user
                }

                //Fetch pictures
                let pictures = try await profileRepository.getPicturesFromUser(fileNames: user.pictures)
                var profilePictures: [PictureModel] = []
                for i in user.pictures.indices {
                    profilePictures.append(PictureModel.storedPicture(user.pictures[i], pictures[i]))
                }

                let finalProfilePictures = profilePictures
                DispatchQueue.main.async {
                    self.userPictures = finalProfilePictures
                    self.isLoading = false
                }
            }catch{
                publishError(message: error.localizedDescription)
            }
        }
    }
    
    //Update only profile fields
    func updateProfile(modified profileFields: [String: Any]) {
        self.isLoading = true
        Task{
            do{
                try await profileRepository.updateProfile(modified: profileFields)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isProfileUpdated = true
                }
            }catch{
                publishError(message: error.localizedDescription)
            }
        }
    }
    
    /**
     Updates the profile pictures

     - Parameter oldPictures: Array of the file names of the pictures that are already uploaded, in their respective order.
     - Parameter newPictures: Array of either: the file name of a picture that is already uploaded or a new picture.
     */
    func updateProfile(newPictures: [PictureModel], modified profileFields: [String: Any]? = nil){
        self.isLoading = true
        Task{
            do{
                try await profileRepository.updateProfile(oldPictures: userProfile?.pictures ?? [], newPictures: newPictures, modified: profileFields)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isProfileUpdated = true
                }
                
            }catch{
                publishError(message: error.localizedDescription)
            }
        }
    }


    private func publishError(message: String) {
        DispatchQueue.main.async {
            self.error = message
            self.isLoading = false
        }
    }
}
