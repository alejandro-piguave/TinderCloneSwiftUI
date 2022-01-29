//
//  ChatView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 24/1/22.
//

import SwiftUI
import Firebase

struct ChatView: View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    let match: MatchModel
    @State private var typingMessage: String = ""
    @State private var messageList: [MessageModel] = []
    @State private var listener: ListenerRegistration? = nil
    @State private var isFirstMessageUpdate = true
    var body: some View {
        VStack{
            Spacer()
            ScrollViewReader{ value in
                ScrollView{
                    LazyVStack{
                        ForEach(messageList){ message in
                            MessageView(message: message, match: match)
                                .id(message.id)
                        }
                    }
                }
                .padding([.leading, .trailing], 8)
                .onChange(of: messageList, perform: { _ in
                    if isFirstMessageUpdate{
                        value.scrollTo(messageList.last?.id, anchor: .bottom)
                        isFirstMessageUpdate = false
                    } else{
                        withAnimation{
                            value.scrollTo(messageList.last?.id, anchor: .bottom)
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
        listener?.remove()
    }
    
    private func performOnAppear(){
        listener = firestoreViewModel.listenToMessages(matchId: match.id, onUpdate: {result in
            switch result{
            case .success(let messages):
                messageList = messages
                return
            case .failure(_): return
            }
        })
    }
    
    private func sendMessage(){
        firestoreViewModel.sendMessage(matchId: match.id, message: typingMessage)
        typingMessage = ""
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(match: MatchModel(id: "efefefeº", userId: "fregregreg",name: "Elon", birthDate: Date(), picture: UIImage(named: "elon_musk")!, lastMessage: "Sup bro"))
    }
}
