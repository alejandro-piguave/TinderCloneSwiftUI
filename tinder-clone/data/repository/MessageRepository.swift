//
//  MessageRepository.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 8/6/23.
//

import Foundation

class MessageRepository {
    
    private init() {}
    
    static let shared = MessageRepository()
    private let storageDataSource: StorageRemoteDataSource = StorageRemoteDataSource.shared
    private let firestoreDataSource: FirestoreRemoteDataSource = FirestoreRemoteDataSource.shared
    
    
    func sendMessage(matchId: String, message: String) throws {
        try firestoreDataSource.sendMessage(matchId: matchId, message: message)
    }
    
    func setChatMatchId(matchId: String) {
        firestoreDataSource.listenedMatchId = matchId
    }
    
    func getMessageListener() -> AsyncThrowingStream<[MessageModel], Error> {
        return firestoreDataSource.messagesListener
    }
    
    func removeListener() {
        firestoreDataSource.listenerRegistration?.remove()
    }
}
