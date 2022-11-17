//
//  EditProfileViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation
import UIKit

struct ProfilePicture: Hashable{
    let filename: String?
    let picture: UIImage
}

class EditProfileViewModel: NSObject, ObservableObject {

    private let firestoreRepository: FirestoreRepository = FirestoreRepository.shared
    private let storageRepository: StorageRepository = StorageRepository.shared
    
    @Published var userProfile: FirestoreUser? = nil
    @Published var userPictures: [ProfilePicture] = []
    @Published var isProfileUpdated: Bool = false
    
    @Published private (set) var isLoading: Bool = true
    @Published private (set) var error: String = ""
    
    func fetchProfile() {
        self.isLoading = true
        Task{
            do{
                //Fetch profile information
                let user = try await firestoreRepository.getUserProfile()
                DispatchQueue.main.async {
                    self.userProfile = user
                }

                //Fetch pictures
                let pictures = try await storageRepository.getPicturesFromUser(fileNames: user.pictures)
                var profilePictures: [ProfilePicture] = []
                for i in user.pictures.indices {
                    profilePictures.append(ProfilePicture(filename: user.pictures[i], picture: pictures[i]))
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
                try await firestoreRepository.updateUserProfile(modified: profileFields)
                
                self.isLoading = false
                self.isProfileUpdated = true
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
    func updateProfile(newPictures: [ProfilePicture], modified profileFields: [String: Any]? = nil){
        self.isLoading = true
        Task{
            let oldPictures = userProfile!.pictures
            //Gets the name of the pictures that are not among the new pictures.
            let filesToDelete = oldPictures.filter({ fileName in
                !newPictures.contains(where: { newPicture in
                    if let newPictureFilename = newPicture.filename {
                        return fileName == newPictureFilename
                    } else {
                        return false
                        
                    }
                })
            })
            
            let picturesToUpload: [UIImage] = newPictures.compactMap({ pictureUpload in
                if pictureUpload.filename == nil{
                    return pictureUpload.picture
                } else {
                    return nil
                }
            })
            
            do{
                async let deletePictures: () = storageRepository.deleteUserPictures(fileNames: filesToDelete)
                async let uploadPictures = storageRepository.uploadUserPictures(picturesToUpload)
                
                let (_, newFileNames): ((), [String]) = try await (deletePictures, uploadPictures)
                
                var updatedFileNames: [String] = []
                var count: Int = 0
                
                newPictures.forEach({
                    if let oldFilename = $0.filename {
                        updatedFileNames.append(oldFilename)
                    } else {
                        updatedFileNames.append(newFileNames[count])
                        count += 1
                    }
                })
                
                //If more values need to be updated then create a copy, otherwise create an empty dictionary
                var allProfileFields: [String: Any] = profileFields ?? [:]
                allProfileFields["pictures"] = updatedFileNames
                
                try await firestoreRepository.updateUserProfile(modified: allProfileFields)
                self.isLoading = false
                self.isProfileUpdated = true
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
