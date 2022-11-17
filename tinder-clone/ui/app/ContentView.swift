//
//  ContentView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 1/1/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    var body: some View {
        NavigationView{
            switch(contentViewModel.authState){
            case .loading:
                LoadingView()
            case .logged:
                HomeView()
            case .unlogged:
                LoginView()
            }
        }.onAppear(perform: {
            contentViewModel.updateAuthState()
        })
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
