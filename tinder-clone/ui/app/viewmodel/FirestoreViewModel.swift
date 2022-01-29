//
//  EditProfileViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 11/1/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import CoreData
import simd

enum DomainError: Error{
    case uploadError, downloadError, parsingError, localSavingError, localfetchingError
}

class FirestoreViewModel: NSObject, ObservableObject{
    private let IMG_MAX_SIZE: Int64 = 10 * 1024 * 1024
    private let viewContext = PersistenceController.shared.container.viewContext
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private var userId: String? {
        Auth.auth().currentUser?.uid
        
    }
    
    func sendMessage(matchId: String, message: String){
        db.collection("matches").document(matchId).collection("messages")
            .addDocument(data:
                            ["message" : message,
                             "senderId" : userId!,
                             "timestamp" : FieldValue.serverTimestamp()])
    }
    
    func listenToMessages(matchId: String, onUpdate: @escaping (Result<[MessageModel], DomainError>) -> ()) -> ListenerRegistration{
        let listener = db.collection("matches").document(matchId).collection("messages").order(by: "timestamp", descending: false).addSnapshotListener({ querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                onUpdate(.failure(.downloadError))
                return
            }
            
            let messages: [MessageModel] = documents.compactMap{ document in
                if let firestoreMessage = try? document.data(as: FirestoreMessage.self){
                    return MessageModel.from(id: document.documentID, firestoreMessage, currentUserId: self.userId!)
                } else {
                    return nil
                }
            }
            onUpdate(.success(messages))
        })
        
        return listener
    }
    
    func fetchMatches(onCompletion: @escaping (Result<[MatchModel], DomainError>) -> ()){
        db.collection("matches").whereField("usersMatched", arrayContains: userId!).getDocuments(completion: {doc, err in
            guard let documentSnapshot = doc, err == nil else{
                onCompletion(.failure(.downloadError))
                return
            }
            var matchList: [MatchModel] = []
            var count = 0
            let maxCount = documentSnapshot.documents.count
            var hasFailed = false
            for document in documentSnapshot.documents{
                if hasFailed{ break }
                let match: FirestoreMatch = try! document.data(as: FirestoreMatch.self)!
                let matchId = match.usersMatched.filter{$0 != self.userId!}.first!
                self.fetchUserProfile(fetchedUserId: matchId, onCompletion: { result in
                    switch result{
                    case .success(let user):
                        self.fetchMainPicture(profileId: matchId, onCompletion: { pictureResult in
                            if hasFailed { return }
                            switch pictureResult{
                            case .success(let picture):
                                matchList.append(MatchModel(id: document.documentID, userId: matchId, name: user.name, birthDate: user.birthDate, picture: picture, lastMessage: nil))
                                
                                count += 1
                                
                                if(count == maxCount){
                                    onCompletion(.success(matchList))
                                }
                                return
                            case .failure(let error):
                                onCompletion(.failure(error))
                                hasFailed = true
                                return
                            }
                        })
                        return
                    case .failure(let error):
                        onCompletion(.failure(error))
                        return
                    }
                })
            }
        })
    }
    
    private func getMatchId(userId1: String, userId2: String) -> String {userId1 > userId2 ? userId1 + userId2 : userId2 + userId1}
    
    func swipeUser(swipedUserId: String, hasLiked: Bool, onMatch: @escaping () -> ()){
        db.collection("users").document(userId!).updateData([
            (hasLiked ? FirestoreUser.CodingKeys.liked.rawValue : FirestoreUser.CodingKeys.passed.rawValue) : FieldValue.arrayUnion([swipedUserId])
        ])
        db.collection("users").document(userId!).collection(FirestoreUser.CodingKeys.liked.rawValue).document(swipedUserId).setData(["exists" : true])
        
        db.collection("users").document(swipedUserId).collection("liked").document(userId!).getDocument(completion: { doc, err in
            if let document = doc, document.exists {
                self.db.collection("matches").document(self.getMatchId(userId1: swipedUserId, userId2: self.userId!))
                        .setData(["usersMatched": [swipedUserId, self.userId!], "timestamp": FieldValue.serverTimestamp()])
  
                onMatch()
            }
        })
        
    }

    func fetchProfiles(onCompletion: @escaping(Result<[UserProfile], DomainError>)->()){
        fetchUserProfile(onCompletion: {result in
            switch result{
            case .success(let user):
                let excludedUsers = user.liked + user.passed
                self.fetchProfiles(isUserMale: user.isMale, userOrientation: user.orientation, excludedUsers: excludedUsers, onCompletion: onCompletion)
                break
            case .failure(let error):
                onCompletion(.failure(error))
                break
            }
        })
    }
    
    private func fetchProfiles(isUserMale: Bool, userOrientation: Orientation, excludedUsers: [String], onCompletion: @escaping(Result<[UserProfile], DomainError>)->()){
        var searchQuery = db.collection("users").whereField(FirestoreUser.CodingKeys.orientation.rawValue, isNotEqualTo: isUserMale ? Orientation.women.rawValue : Orientation.men.rawValue)
        if userOrientation != .both{
            searchQuery = searchQuery.whereField(FirestoreUser.CodingKeys.isMale.rawValue, isEqualTo: userOrientation == .men)
        }

        searchQuery.getDocuments(completion: { (snapshot, err) in
            guard let documentSnapshot = snapshot, err == nil else {
                onCompletion(.failure(.downloadError))
                return
            }

            var profileList: [UserProfile] = []
            var count = 0
            var hasFailed = false
            
            let filteredDocumentList = documentSnapshot.documents.filter{ $0.documentID != self.userId && !excludedUsers.contains($0.documentID)}
            
            if filteredDocumentList.isEmpty{
                onCompletion(.success([]))
                 return
            }
            
            let maxCount = filteredDocumentList.count
            
            for document in filteredDocumentList{
                if let user = try? document.data(as: FirestoreUser.self){
                    let userName = user.name
                    let userAge = user.age
                    self.fetchProfilePictures(profileId: document.documentID, onCompletion: { result in
                        if hasFailed {return}
                        switch result{
                        case .success(let images):
                            profileList.append(UserProfile(userId: document.documentID, name: userName, age: userAge, pictures: images))
                            
                            count += 1
                            
                            if(count == maxCount){
                                onCompletion(.success(profileList))
                            }
                            return
                        case .failure(let error):
                            onCompletion(.failure(error))
                            hasFailed = true
                            return
                        }
                    })
                } else {
                    onCompletion(.failure(.parsingError))
                    break
                }
            }
            
        })
    }
    
    private func fetchMainPicture(profileId: String, onCompletion: @escaping(Result<UIImage, DomainError>)->()){
        let picRef = storage.child("users").child(profileId).child("profile_pic_0.jpg")
        picRef.getData(maxSize: self.IMG_MAX_SIZE) { data, error in
                if error != nil {
                    onCompletion(.failure(.downloadError))
                } else {
                    onCompletion(.success(UIImage(data: data!)!))
                }
        }
    }
    
    private func fetchProfilePictures(profileId: String, onCompletion: @escaping(Result<[UIImage], DomainError>)->()){
        let userRef = storage.child("users").child(profileId)
        userRef.listAll(completion: {result, error in
            if error != nil{
                onCompletion(.failure(.downloadError))
                return
            }
            var profilePictures: [UIImage] = []
            var count = 0
            var hasFailed = false
            for picRef in result.items{
                picRef.getData(maxSize: self.IMG_MAX_SIZE) { data, error in
                    if hasFailed { return }
                    if error != nil {
                        onCompletion(.failure(.downloadError))
                        hasFailed = true
                    } else {
                        profilePictures.append(UIImage(data: data!)!)
                        count += 1
                        if(count == result.items.count){
                            onCompletion(.success(profilePictures))
                        }
                    }
                }
            }
        })
    }
    
    
    func fetchUserPictures(onCompletion: @escaping (Result<[UIImage],DomainError>)->(), onUpdate: @escaping (Result<[UIImage],DomainError>)->()){
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = viewContext
        context.automaticallyMergesChangesFromParent = true
        context.perform {
            let fetchRequest = ProfilePicture.fetchRequest()
            let descriptor = NSSortDescriptor(key: "position", ascending: true)
            fetchRequest.sortDescriptors = [descriptor]
            if let localPictures = try? context.fetch(fetchRequest){
                let imageData = localPictures.compactMap{ $0.picture }
                let images: [UIImage] = imageData.compactMap{ UIImage(data: $0) }
                DispatchQueue.main.async {
                    onCompletion(.success(images))
                    self.checkMetadata(localPictures, onUpdate)
                }
            } else{
                DispatchQueue.main.async {
                    onCompletion(.failure(.localfetchingError))
                }
            }
        }
    }
    
    private func checkMetadata(_ localPictures: [ProfilePicture], _ onUpdate: @escaping (Result<[UIImage],DomainError>)->()){
        let timestamps = localPictures.compactMap{ $0.timestamp }
        let userRef = storage.child("users").child(userId!)
        userRef.listAll(completion: {result, error in
            if error != nil{
                onUpdate(.failure(.downloadError))
                return
            }
            var updatedLocalPictures: [LocalPicture] = []
            var count = 0
            var hasChanged = false
            for (index, picRef) in result.items.enumerated(){
                picRef.getMetadata { metadata, error in
                    if error != nil {
                        onUpdate(.failure(.downloadError))
                    } else if let picTimestamp = metadata?.timeCreated{
                            print("This is picRef = \(picRef.name)")
                        if(index < timestamps.count && picTimestamp == timestamps[index]){
                            print("Timestamps are equal, they are the same image")
                            let localPicture = localPictures[index]
                            updatedLocalPictures.append(LocalPicture(data: localPicture.picture, timestamp: picTimestamp, position: localPicture.position))
                            count += 1
                        }else if let timestampIndex = timestamps.firstIndex(of: picTimestamp){
                            
                            print("Timestamp is the timestamp of a picture in another position")
                            let localPicture = localPictures[timestampIndex]
                            updatedLocalPictures.append(LocalPicture(data: localPicture.picture, timestamp: picTimestamp, position: localPicture.position))
                            hasChanged = true
                            count += 1
                        }else{
                            print("Timestamp not found, downloading the picture...")

                            picRef.getData(maxSize: self.IMG_MAX_SIZE) { data, error in
                              if error != nil {
                                  onUpdate(.failure(.downloadError))
                              } else {
                                  hasChanged = true
                                  updatedLocalPictures.append(LocalPicture(data: data, timestamp: picTimestamp, position: Int16(index)))
                                  count += 1
                                  
                                  //PERFORM UPDATE
                                  if(count == result.items.count){
                                      self.performImageUpdate(updatedLocalPictures, onUpdate)
                                  }
                              }
                            }
                        }
                        
                        //PERFORM UPDATE
                        if(count == result.items.count && hasChanged){
                            self.performImageUpdate(updatedLocalPictures, onUpdate)
                        }
                    } else {
                        onUpdate(.failure(.downloadError))
                    }
                }
            }
        })
    }
    
    private func performImageUpdate(_ updatedPictures: [LocalPicture], _ onUpdate: @escaping (Result<[UIImage], DomainError>)->()){
        let fetchRequest = ProfilePicture.fetchRequest()
        if let localPictures = try? viewContext.fetch(fetchRequest){
            for updatedPicture in updatedPictures {
                if let localPicture = localPictures.first(where: { $0.position == updatedPicture.position}){
                    localPicture.picture = updatedPicture.data
                    localPicture.timestamp = updatedPicture.timestamp
                } else {
                    let newProfilePic = ProfilePicture(context: viewContext)
                    newProfilePic.timestamp = updatedPicture.timestamp
                    newProfilePic.picture = updatedPicture.data
                    newProfilePic.position = updatedPicture.position
                }
            }
            
            do {
                try viewContext.save()
                
                let returnedImages: [UIImage] = updatedPictures.sorted(by: { $0.position < $1.position }).compactMap{ UIImage(data: $0.data!) }
                
                onUpdate(.success(returnedImages))
            } catch {
                onUpdate(.failure(.localSavingError))
            }
        } else{
            onUpdate(.failure(.localfetchingError))
            return
        }
        

    }
    
    func fetchUserProfile(fetchedUserId: String? = nil ,onCompletion: @escaping (Result<FirestoreUser, DomainError>)->()){
        let usedId: String = fetchedUserId ?? userId!
        db.collection("users").document(usedId).getDocument { (document, error) in
            if error != nil{
                onCompletion(.failure(.downloadError))
                return
            }
            
            if let user = try? document?.data(as: FirestoreUser.self){
                onCompletion(.success(user))
            } else {
                onCompletion(.failure(.parsingError))
            }
        }
    }
    func updateUserProfile(modified profileFields: [String: Any], onCompletion: @escaping (Result<Void,DomainError>) -> () ){
        let ref = db.collection("users").document(userId!)
        ref.updateData(profileFields) { err in
            if err != nil {
                onCompletion(.failure(.uploadError))
            } else {
                print("Document successfully updated")
                onCompletion(.success(()))
            }
        }
    }
    func updateUserProfile(pictures: [UIImage], previousPicCount: Int, onCompletion: @escaping (Result<Void,DomainError>) -> () ){
        uploadProfilePictures(pictures, previousPicCount: previousPicCount, onCompletion: onCompletion)
    }
    
    func updateUserProfile(modified profileFields: [String: Any], pictures: [UIImage], previousPicCount: Int,  onCompletion: @escaping (Result<Void,DomainError>) -> () ){
        let ref = db.collection("users").document(userId!)
        var otherTaskFinished = false
        ref.updateData(profileFields) { err in
            if err != nil {
                onCompletion(.failure(.uploadError))
            } else {
                print("Document successfully updated")
                if(otherTaskFinished){
                    onCompletion(.success(()))
                } else{
                    otherTaskFinished = true
                }
            }
        }
        
        uploadProfilePictures(pictures, previousPicCount: previousPicCount, onCompletion: {result in
            if(otherTaskFinished){
                onCompletion(result)
            } else {
                otherTaskFinished = true
            }
        })
    }
    
    func createUserProfile(name: String, birhtDate: Date, bio: String, isMale: Bool, orientation: Orientation, pictures: [UIImage], onCompletion: @escaping (Result<Void, DomainError>) -> ()){
        
        let firestoreUser = FirestoreUser(name: name, birthDate: birhtDate, bio: bio, isMale: isMale, orientation: orientation, liked: [], passed: [])
        
        do {
            try db.collection("users").document(userId!).setData(from: firestoreUser)
        } catch {
            onCompletion(.failure(.uploadError))
            return
        }
        uploadProfilePictures(pictures, onCompletion: onCompletion)
    }
    
    
    private func uploadProfilePictures(_ pics: [UIImage], previousPicCount: Int = 0, onCompletion: @escaping (Result<Void,DomainError>) -> ()){
        let userRef = storage.child("users").child(userId!)
        var localPictures: [LocalPicture] = []
        var count = 0
        
        if(previousPicCount > pics.count){
            for index in pics.count..<previousPicCount{
                let picRef = userRef.child("profile_pic_\(index).jpg")
                picRef.delete { error in
                    if error != nil {
                        onCompletion(.failure(.uploadError))
                    }
                }
            }
        }
        
        for (index, pic) in pics.enumerated(){
            let data = pic.jpegData(compressionQuality: 1.0)!
            let picRef = userRef.child("profile_pic_\(index).jpg")
            localPictures.append(LocalPicture())
            picRef.putData(data, metadata: nil) { (metadata, error) in
                guard let pictureMetadata = metadata else {
                    onCompletion(.failure(.downloadError))
                    return
                }
                localPictures[index].timestamp = pictureMetadata.timeCreated
                localPictures[index].data = data
                localPictures[index].position = Int16(index)
                
                count += 1
                
                if(count == pics.count){
                    let saveResult = self.saveLocalPictures(localPictures)
                    onCompletion(saveResult)
                }
            }
        }
    }
    
    private func deleteAllLocalPictures() ->Result<Void, DomainError>{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ProfilePicture.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        let batchDeleteFetchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteFetchRequest.resultType = .resultTypeObjectIDs
        do {
            let batchDelete = try viewContext.execute(batchDeleteFetchRequest)
                as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result
                as? [NSManagedObjectID]
            else { return .failure(.localSavingError)}

            let deletedObjects: [AnyHashable: Any] = [
                NSDeletedObjectsKey: deleteResult
            ]

            // Merge the delete changes into the managed
            // object context
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: deletedObjects,
                into: [viewContext]
            )
            return .success(())
        } catch {
            return .failure(.localSavingError)
        }
    }
    
    private func saveLocalPictures(_ localPictures: [LocalPicture]) -> Result<Void,DomainError>{
        let deleteResult = deleteAllLocalPictures()
        switch deleteResult{
        case .failure(_):
            return deleteResult
        case .success(_):
            for picture in localPictures {
                let newProfilePic = ProfilePicture(context: viewContext)
                newProfilePic.timestamp = picture.timestamp
                newProfilePic.picture = picture.data
                newProfilePic.position = picture.position
            }

            do {
                try viewContext.save()
                return .success(())
            } catch {
                return .failure(.localSavingError)
            }
        }
    }
}

struct LocalPicture{
    var data: Data? = nil
    var timestamp: Date? = nil
    var position: Int16 = 0
}
