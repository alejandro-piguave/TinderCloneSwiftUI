//
//  LoginView.swift
//  Tinder 2
//
//  Created by Alejandro Piguave on 31/12/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack{
            Spacer()
            Image("logo").resizable()
                .scaledToFit()
                .frame(width: 150).padding(40).aspectRatio( contentMode: .fit)
            
            Button{
                authViewModel.signInWithGoogle(controller: getRootViewController())
            } label: {
                HStack{
                    Image("icons8-google-48")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Sign In with Google")
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 10)
                
            }.background(.white).cornerRadius(22)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: AppColor.appColors, startPoint: .leading, endPoint: .trailing)).ignoresSafeArea()
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View{
    func getRootViewController() -> UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else{
            return .init()
        }
        
        return root
    }
    
}
