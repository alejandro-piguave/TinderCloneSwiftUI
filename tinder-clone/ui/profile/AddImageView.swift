//
//  AddImageView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 3/1/22.
//

import SwiftUI

struct AddImageView: View {
    @State private var isTapped: Bool = false
    let action: () -> ()
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Spacer()
                .frame(maxWidth: .infinity)
                .aspectRatio(0.6, contentMode: .fit)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(8)
                .overlay(Rectangle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .cornerRadius(8)
                            .foregroundColor(Color(UIColor.systemGray4))
                         
                )
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundGradient(colors: AppColor.appColors)
                .background(Capsule().fill(.white))
                .offset(x: 8, y: 8)
        }
        .opacity(isTapped ? 0.5 : 1)
        .scaleEffect(isTapped ? 0.9 : 1)
        .padding(8)
        .gesture(
            TapGesture()
                .onEnded{ _ in
                    print("on End Tap")
                    withAnimation(Animation.linear(duration: 0.1)){
                        self.isTapped = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.isTapped = false
                        action()
                    }
                })
    }
}

struct AddImageView_Previews: PreviewProvider {
    static var previews: some View {
        AddImageView{
            
        }
    }
}
