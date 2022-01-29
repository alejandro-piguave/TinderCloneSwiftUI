//
//  MatchChatView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 23/1/22.
//

import SwiftUI

struct MatchItemView: View {
    let model: MatchModel
    var body: some View {
        HStack{
            Image(uiImage: model.picture).centerCropped().frame(width: 50, height: 50).cornerRadius(25)
            VStack(alignment: .leading){
                HStack{
                    Text(model.name).bold()
                    Text("\(model.age)").fontWeight(.light)
                }
                Text("Say something nice!")
                    .fontWeight(.light)
            }.padding(.leading, 6)
            Spacer()
        }.padding([.top,.bottom],6)
            
    }
}

struct MatchChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            MatchItemView(model: MatchModel(id: "fefregergerger",userId: "efwerfgregrger",name: "Elon", birthDate: Date(), picture: UIImage(named:"elon_musk")!, lastMessage: ""))
        }.navigationTitle("Messages")
    }
}
