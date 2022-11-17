//
//  ChatView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 24/1/22.
//

import SwiftUI
import Firebase

struct ChatView: View {
    let match: MatchModel
    @StateObject var chatViewModel =  ChatViewModel()
    @State private var typingMessage: String = ""
    @State private var isFirstMessageUpdate = true
    var body: some View {
        VStack{
            Spacer()
            ScrollViewReader{ value in
                ScrollView{
                    LazyVStack{
                        ForEach(chatViewModel.messageList){ message in
                            MessageView(message: message, match: match)
                                .id(message.id)
                        }
                    }
                }
                .padding([.leading, .trailing], 8)
                .onChange(of: chatViewModel.messageList, perform: { _ in
                    if isFirstMessageUpdate{
                        value.scrollTo(chatViewModel.messageList.last?.id, anchor: .bottom)
                        isFirstMessageUpdate = false
                    } else{
                        withAnimation{
                            value.scrollTo(chatViewModel.messageList.last?.id, anchor: .bottom)
                        }
                    }
                })
            }
            HStack {
                   TextField("send-message-placeholder", text: $typingMessage)
                      .textFieldStyle(RoundedBorderTextFieldStyle())
                      .frame(minHeight: CGFloat(30))
                    Button(action: sendMessage) {
                        Text("send-message")
                    }.disabled(typingMessage.isBlank)
            }.frame(minHeight: CGFloat(50)).padding([.trailing, .leading])
        }
        .navigationTitle(match.name)
        .onAppear(perform: performOnAppear)
        .onDisappear(perform: performOnDisappear)
    }
    
    private func performOnDisappear(){
        chatViewModel.removeListener()
    }
    
    private func performOnAppear(){
        chatViewModel.listenToMessages(matchId: match.id)
    }
    
    private func sendMessage(){
        chatViewModel.sendMessage(matchId: match.id, message: typingMessage)
        typingMessage = ""
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(match: MatchModel(id: "efefefeº", timestamp: Date(), userId: "fregregreg",name: "Elon", birthDate: Date(), picture: UIImage(named: "elon_musk")!, lastMessage: "Sup bro"))
    }
}
