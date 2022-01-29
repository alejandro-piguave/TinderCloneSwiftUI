//
//  ContentView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 1/1/22.
//

import SwiftUI

struct ContentView: View {
    @State private var authState: AuthState? = .loading
    @EnvironmentObject var loginViewModel: AuthViewModel
    
    @ViewBuilder
    func contentBuilder() -> some View {
        switch(loginViewModel.authState){
        case .loading:
            LoadingView()
        case .logged:
            HomeView()
        case .unlogged:
            LoginView()
        case .pendingInformation:
            CreateProfileView()
        }
    }
    
    var body: some View {
        contentBuilder()
            .onAppear(perform: {
                loginViewModel.updateAuthState()
            })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
