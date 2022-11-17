//
//  FirestoreRepository.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ParsingError: LocalizedError{
    let message: String
    public var errorDescription: String? { message }
}

class FirestoreRepository{
    static let shared = FirestoreRepository()
    private var userId: String? { Auth.auth().currentUser?.uid }
    private let db = Firestore.firestore()
    private init(){}
    
    
    func createUserProfile(name: String, birthDate: Date, bio: String, isMale: Bool, orientation: Orientation, pictures: [String]) async throws{
        let firestoreUser = FirestoreUser(name: name, birthDate: birthDate, bio: bio, isMale: isMale, orientation: orientation, pictures: pictures, liked: [], passed: [])
        
        try db.collection("users").document(userId!).setData(from: firestoreUser)
    }
    
    //Returns true if a match was created as a result of this swipe
    func swipeUser(swipedUserId: String, hasLiked: Bool) async throws -> Bool{
        try await db.collection("users").document(userId!).updateData([
            (hasLiked ? FirestoreUser.CodingKeys.liked.rawValue : FirestoreUser.CodingKeys.passed.rawValue) : FieldValue.arrayUnion([swipedUserId])
        ])
        try await db.collection("users").document(userId!).collection(FirestoreUser.CodingKeys.liked.rawValue).document(swipedUserId).setData(["exists" : true])
        
        if try await hasUserLikedBack(swipedUserId: swipedUserId){
            try await self.db.collection("matches").document(self.getMatchId(userId1: swipedUserId, userId2: self.userId!))
                    .setData(["usersMatched": [swipedUserId, self.userId!], "timestamp": FieldValue.serverTimestamp()])
            return true
        }
        
        return false
    }
    
    
    private func getMatchId(userId1: String, userId2: String) -> String {userId1 > userId2 ? userId1 + userId2 : userId2 + userId1}

    private func hasUserLikedBack(swipedUserId: String) async throws -> Bool {
        let result = try await db.collection("users").document(swipedUserId).collection("liked").document(userId!).getDocument()
        return result.exists
    }
    
    //Obtains the profile of a user given its id. If left blank, it retrieves the profile of the current logged user.
    func getUserProfile(fetchedUserId: String? = nil) async throws -> FirestoreUser{
        let usedId: String = fetchedUserId ?? userId!
        let result  = try await db.collection("users").document(usedId).getDocument()

        guard let user = try result.data(as: FirestoreUser.self) else{
            throw ParsingError(message: "Could not parse the user profile object.")
        }

        return user
    }
    
    
    func getCompatibleUsers(isUserMale: Bool, userOrientation: Orientation, excludedUsers: [String]) async throws -> [FirestoreUser]{
        var searchQuery = db.collection("users").whereField(FirestoreUser.CodingKeys.orientation.rawValue, isNotEqualTo: isUserMale ? Orientation.women.rawValue : Orientation.men.rawValue)
        if userOrientation != .both{
            searchQuery = searchQuery.whereField(FirestoreUser.CodingKeys.isMale.rawValue, isEqualTo: userOrientation == .men)
        }

        let result = try await searchQuery.getDocuments()
        let filteredDocumentList = result.documents.filter{ $0.documentID != self.userId && !excludedUsers.contains($0.documentID)}
        if filteredDocumentList.isEmpty {
            return []
        }
        
        let profiles: [FirestoreUser] = try filteredDocumentList.map({
            guard let parsedProfile = try $0.data(as: FirestoreUser.self) else {
                throw ParsingError(message: "Could not parse user profile object.")
            }

            return parsedProfile
        })
        
        return profiles
    }
    
    
    //Update profile
    
    func updateUserProfile(modified profileFields: [String: Any]) async throws {
        let ref = db.collection("users").document(userId!)
        try await ref.updateData(profileFields)
    }
    
    //Matches
    
    func getMatchedUsers() async throws -> [MatchProfile] {
        let result = try await db.collection("matches").whereField("usersMatched", arrayContains: userId!).getDocuments()

        let matches: [Match] = try result.documents.map({ document in
            let match: FirestoreMatch = try document.data(as: FirestoreMatch.self)!
            return Match(id: match.id!, userId: match.usersMatched.filter{$0 != self.userId!}.first!, timestamp: match.timestamp)
        })
        
        let matchedUsers = try await getMatchedUsers(matches: matches)
        return matchedUsers
    }
    
    private func getMatchedUsers(matches: [Match]) async throws -> [MatchProfile]{
        try await withThrowingTaskGroup(of: (FirestoreUser, Match).self, body: { group in
            for match in matches {
                group.addTask {
                    let user = try await self.getUserProfile(fetchedUserId: match.userId)
                    return (user, match)
                }
            }
            
            var profiles: [MatchProfile] = []
            
            for try await (user, match) in group {
                profiles.append(MatchProfile(id: match.id, profile: user, timestamp:  match.timestamp))
            }
            
            return profiles
        })
    }
    
    //Messages
    
    func sendMessage(matchId: String, message: String) {
        db.collection("matches").document(matchId).collection("messages")
            .addDocument(data:
                            ["message" : message,
                             "senderId" : userId!,
                             "timestamp" : FieldValue.serverTimestamp()])
    }
    
    var listenedMatchId: String = ""
    var listenerRegistration: ListenerRegistration? = nil
    
    var messagesListener: AsyncThrowingStream<[MessageModel], Error>{
        AsyncThrowingStream<[MessageModel], Error> { continuation in
            listenerRegistration = db.collection("matches").document(listenedMatchId).collection("messages").order(by: "timestamp", descending: false).addSnapshotListener({ querySnapshot, error in
                
                guard let documents = querySnapshot?.documents, error == nil else {
                    continuation.finish(throwing: error)
                    return
                }
                
                let messages: [MessageModel] = documents.compactMap{ document in
                    if let firestoreMessage = try? document.data(as: FirestoreMessage.self){
                        return MessageModel.from(id: document.documentID, firestoreMessage, currentUserId: self.userId!)
                    } else {
                        return nil
                    }
                }
                
                continuation.yield(messages)
            })
        }
    }
}

struct MessageListener: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Int
    var current = 1

    mutating func next() async -> Int? {
        guard !Task.isCancelled else {
            return nil
        }

        let result = current
        current += 1
        return result
    }

    func makeAsyncIterator() -> MessageListener { self }
}
struct Match{
    let id: String
    let userId: String
    let timestamp: Date
}

struct MatchProfile{
    let id: String
    let profile: FirestoreUser
    let timestamp: Date
}
