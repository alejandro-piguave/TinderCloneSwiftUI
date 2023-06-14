//
//  ProfileRepository.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 8/6/23.
//

import Foundation
import UIKit


class ProfileRepository {
    
    private init() {}
    
    static let shared = ProfileRepository()
    
    private let authDataSource: AuthRemoteDataSource = AuthRemoteDataSource.shared
    private let storageDataSource: StorageRemoteDataSource = StorageRemoteDataSource.shared
    private let firestoreDataSource: FirestoreRemoteDataSource = FirestoreRemoteDataSource.shared
    
    
    func signIn(controller: UIViewController) async throws {
        try await authDataSource.signIn(controller: controller, authType: .existingUser)
    }
    
    func signUp(controller: UIViewController, from createProfileModel: CreateProfileModel) async throws {
        try await authDataSource.signIn(controller: controller, authType: .newUser)
        
        let fileNames = try await storageDataSource.uploadUserPictures(createProfileModel.pictures)

        try await firestoreDataSource.createUserProfile(name: createProfileModel.name, birthDate: createProfileModel.birthDate, bio: createProfileModel.bio, isMale: createProfileModel.isMale, orientation: createProfileModel.orientation, pictures: fileNames)
    }
    
    func getUserProfile() async throws -> FirestoreUser{
        let userId = try firestoreDataSource.getUserId()
        return try await firestoreDataSource.getUserProfile(userId: userId)
    }
    
    func getPicturesFromUser(fileNames: [String]) async throws -> [UIImage]{
        let userId = try firestoreDataSource.getUserId()
        return try await storageDataSource.getPicturesFromUser(userId: userId, fileNames: fileNames)
    }
    
    
    //Update only profile fields
    func updateProfile(modified profileFields: [String: Any]) async throws {
        try await firestoreDataSource.updateUserProfile(modified: profileFields)
    }
    
    /**
     Updates the profile pictures

     - Parameter oldPictures: Array of the file names of the pictures that are already uploaded, in their respective order.
     - Parameter newPictures: Array of either: the file name of a picture that is already uploaded or a new picture.
     */
    func updateProfile(oldPictures: [String], newPictures: [PictureModel], modified profileFields: [String: Any]? = nil) async throws{
        //Gets the name of the pictures that are not among the new pictures.
        let filesToDelete = oldPictures.filter({fileName in
            !newPictures.contains(where: { newPicture in
                if case .storedPicture(let filePath, _) = newPicture {
                    return filePath == fileName
                } else {
                    return false
                    
                }
            })
        })
        
        let picturesToUpload: [UIImage] = newPictures.compactMap({ pictureUpload in
            if case .newPicture(let image) = pictureUpload {
                return image
            } else {
                return nil
            }
        })
        
      
        async let deletePictures: () = storageDataSource.deleteUserPictures(fileNames: filesToDelete)
        async let uploadPictures = storageDataSource.uploadUserPictures(picturesToUpload)
        
        let (_, newFileNames): ((), [String]) = try await (deletePictures, uploadPictures)
        
        var updatedFileNames: [String] = []
        var count: Int = 0
        
        newPictures.forEach({ newPicture in
            if case .storedPicture(let oldFileName, _) = newPicture {
                updatedFileNames.append(oldFileName)
            } else {
                updatedFileNames.append(newFileNames[count])
                count += 1
            }
        })
        
        //If more values need to be updated then create a copy, otherwise create an empty dictionary
        var allProfileFields: [String: Any] = profileFields ?? [:]
        allProfileFields["pictures"] = updatedFileNames
        
        try await firestoreDataSource.updateUserProfile(modified: allProfileFields)
    }
    
}
