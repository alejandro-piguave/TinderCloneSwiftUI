//
//  MessageView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 24/1/22.
//

import SwiftUI

struct MessageView: View {
    let message: MessageModel
    let match: MatchModel
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if !message.isCurrentUser {
                Image(uiImage: match.picture)
                    .centerCropped()
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
            } else {
                Spacer()
            }
            ContentMessageView(contentMessage: message.message,
                               isCurrentUser: message.isCurrentUser)
            if(!message.isCurrentUser){
                Spacer()
            }
        }
    }
    
    
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: MessageModel(id: "efefefefe", isCurrentUser: true, timestamp: Date(), message: "sfrffrdref"), match: MatchModel(id: "fefefe", userId: "ededefd", name: "Elon", birthDate: Date(), picture: UIImage(), lastMessage: nil))
    }
}
