//
//  LoadingView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 3/1/22.
//

import SwiftUI

struct LoadingView: View {
    
    @State private var isAnimating = false
    var body: some View {
        VStack{
            Spacer()
            Image("logo").resizable()
                .scaledToFit()
                .frame(width: 150).padding(40).aspectRatio( contentMode: .fit)
                .scaleEffect(self.isAnimating ? 1: 1.25)
                .animation(Animation.easeOut(duration: 1).repeatForever(), value: isAnimating)
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1).repeatForever()){
                        self.isAnimating = true
                    }
                }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: AppColor.appColors, startPoint: .leading, endPoint: .trailing)).ignoresSafeArea()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
