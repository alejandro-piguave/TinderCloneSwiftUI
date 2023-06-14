//
//  ChatViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 17/11/22.
//

import Foundation

class ChatViewModel: NSObject, ObservableObject {

    private let messageRepository = MessageRepository.shared
    
    @Published private (set) var messageList: [MessageModel] = []
    
    @Published private (set) var isLoading: Bool = true
    @Published private (set) var error: String = ""
    
    
    func sendMessage(matchId: String, message: String){
        do {
            try messageRepository.sendMessage(matchId: matchId, message: message)
        } catch {
            //Haven't thought about error handling yet
        }
    }
    
    func listenToMessages(matchId: String){
        messageRepository.setChatMatchId(matchId: matchId)
        Task{
            do{
                for try await messageList in messageRepository.getMessageListener() {
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
        messageRepository.removeListener()
    }
}
