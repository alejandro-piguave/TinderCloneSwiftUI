//
//  StorageRepository.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation


import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI


struct StorageError : Error{
    let message: String
}
class StorageRepository{
    private static let IMG_MAX_SIZE: Int64 = 10 * 1024 * 1024
    static let shared = StorageRepository()
    private let storage = Storage.storage().reference()
    private var userId: String? { Auth.auth().currentUser?.uid }
    private init(){}
    
    
    
    func uploadUserPictures(_ pics: [UIImage]) async throws -> [String] {
        try await withThrowingTaskGroup(of: (Int, String).self, body: { group in
            for (index, pic) in pics.enumerated(){
                group.addTask {
                    let fileName = try await self.uploadUserPicture(picture: pic)
                    return (index, fileName)
                }
            }
            
            var fileNames: [(Int, String)] = []
            
            for try await (index, fileName) in group{
                fileNames.append((index, fileName))
            }
            
            //Sorts the elements by their index and returns only the file names.
            return fileNames.sorted(by: { $0.0 > $1.0}).map({ $0.1 })
        })
    }
    
    
    private func uploadUserPicture(picture: UIImage) async throws -> String{
        guard let data = picture.jpegData(compressionQuality: 1.0) else {
            throw StorageError(message: "No data found in picture")
        }
        let fileName = UUID().uuidString + ".jpg"
        let picRef = storage.child("users").child(userId!).child(fileName)
        
        return try await withCheckedThrowingContinuation{ continuation in
            picRef.putData(data, metadata: nil) { (metadata, error) in
                if let error = error {
                    continuation.resume(throwing : error)
                }
                continuation.resume(returning: fileName)
            }
        }
    }
    
    //usersMap is a map with key-value pairs where the key is the id of the user and the value is a list with the file names of its pictures
    func getPicturesFromUsers(usersMap: [String: [String]]) async throws -> [String: [UIImage]]{
        try await withThrowingTaskGroup(of: (String, [UIImage]).self, body: { group in
            for (key, value) in usersMap {
                group.addTask {
                    let pictures = try await self.getPicturesFromUser(userId: key, fileNames: value)
                    return (key, pictures)
                }
            }
            
            var picturesMap: [String: [UIImage]] = [:]
            
            for try await (userId, pictures) in group {
                picturesMap[userId] = pictures
            }
            
            return picturesMap
        })
    }
    
    func getPictureFromUsers(usersMap: [String: String]) async throws -> [String: UIImage]{
        try await withThrowingTaskGroup(of: (String, UIImage).self, body: { group in
            for (key, value) in usersMap {
                group.addTask {
                    let picture = try await self.getPictureFromUser(userId: key, fileName: value)
                    return (key, picture)
                }
            }
            
            var picturesMap: [String: UIImage] = [:]
            
            for try await (userId, picture) in group {
                picturesMap[userId] = picture
            }
            
            return picturesMap
        })
    }
    
    //Get pictures from own user
    func getPicturesFromUser(fileNames: [String]) async throws -> [UIImage]{
        try await getPicturesFromUser(userId: self.userId!, fileNames: fileNames)
    }
    
    func getPicturesFromUser(userId: String, fileNames: [String]) async throws -> [UIImage]{
        try await withThrowingTaskGroup(of: (Int, UIImage).self, body: { group in
            for (index, fileName) in fileNames.enumerated() {
                group.addTask {
                    let picture = try await self.getPictureFromUser(userId: userId, fileName: fileName)
                    return (index, picture)
                }
            }
            
            var pictures: [(Int, UIImage)] = []
            
            for try await (index, picture) in group {
                pictures.append((index, picture))
            }
            
            //Sorts the elements by their index and returns only the images.
            return pictures.sorted(by: { $0.0 > $1.0}).map({ $0.1 })
        })
    }
    
    private func getPictureFromUser(userId: String, fileName: String) async throws -> UIImage{
        try await withCheckedThrowingContinuation{ continuation in
            let pictureRef = storage.child("users").child(userId).child(fileName)
            pictureRef.getData(maxSize: StorageRepository.IMG_MAX_SIZE, completion: { data, error in
                if let error = error{
                    continuation.resume(throwing: error)
                    return
                }

                guard let imageData = data, let image = UIImage(data: imageData) else {
                    continuation.resume(throwing: StorageError(message: "Image not found"))
                    return
                }

                continuation.resume(returning: image)
            })
        }
    }
    
    
    //Update profile
    
    func deleteUserPictures(fileNames: [String]) async throws {
        try await withThrowingTaskGroup(of: Void.self, body: { group in
            for fileName in fileNames {
                group.addTask {
                    try await self.deleteUserPicture(fileName: fileName)
                    return
                }
            }
            
            for try await _ in group {}
            return
        })
    }
    
    private func deleteUserPicture(fileName: String) async throws{
        let fileRef = storage.child("users").child(userId!).child(fileName)
        try await fileRef.delete()
    }
}
