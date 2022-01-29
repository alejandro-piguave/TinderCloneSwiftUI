//
//  MatchView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 23/1/22.
//

import SwiftUI

struct MatchView: View {
    let matchName: String
    let matchImage: UIImage
    let onSendMessageButtonClicked: () -> ()
    let onKeepSwipingClicked: () -> ()
    var body: some View {
        VStack{
            Spacer()
            Image("its-a-match").resizable().scaledToFit()
            Text(String(format: NSLocalizedString("its-a-match-text", comment: "Text for when two users match"), matchName)).font(.subheadline).fontWeight(.bold).foregroundColor(.white).padding()
            
            Image(uiImage: matchImage)
                .centerCropped().aspectRatio(0.7, contentMode: .fit)
                .cornerRadius(10)
            Button(action: onSendMessageButtonClicked, label: {
                Text("send-message").padding([.leading,.trailing], 25).padding([.top, .bottom], 15)
            }).background(.white).cornerRadius(25).padding(.top)
            
            Button(action: onKeepSwipingClicked, label: {
                Text("keep-swiping").foregroundColor(.white)
            }).padding(12)
            Spacer()
        }
        .padding()
        .background(LinearGradient(colors: AppColor.appColors.map{$0.opacity(0.8)}, startPoint: .leading, endPoint: .trailing))
    }
}

struct MatchView_Previews: PreviewProvider {
    static var previews: some View {
        MatchView(matchName: "Elon", matchImage: UIImage(named: "elon_musk")!, onSendMessageButtonClicked: {}, onKeepSwipingClicked: {})
    }
}
