//
//  ChatViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 17/11/22.
//

import Foundation

class ChatViewModel: NSObject, ObservableObject {

    private let firestoreRepository: FirestoreRepository = FirestoreRepository.shared
    
    @Published private (set) var messageList: [MessageModel] = []
    
    @Published private (set) var isLoading: Bool = true
    @Published private (set) var error: String = ""
    
    
    func sendMessage(matchId: String, message: String){
        firestoreRepository.sendMessage(matchId: matchId, message: message)
    }
    
    func listenToMessages(matchId: String){
        firestoreRepository.listenedMatchId = matchId
        Task{
            do{
                for try await messageList in firestoreRepository.messagesListener{
                    DispatchQueue.main.async {
                        self.messageList = messageList
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    func removeListener(){
        firestoreRepository.listenerRegistration?.remove()
    }
}
