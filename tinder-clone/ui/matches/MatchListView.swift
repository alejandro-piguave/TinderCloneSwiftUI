//
//  ChatView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 2/1/22.
//

import SwiftUI

struct MatchListView: View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State private var loading = true
    @State private var matches: [MatchModel] = []

    var body: some View {
        VStack{
            if(loading){
                ProgressView()
            }else {
                if(matches.isEmpty){
                    Text("no-matches-yet")
                } else {
                    List(matches){ item in
                        NavigationLink(destination: ChatView(match: item)){
                            MatchItemView(model: item)
                        }
                    }
                }
            }
        }
        .navigationTitle("messages")
        .onAppear(perform: performOnAppear)
        
    }
    
    private func onReceiveMatches(result: Result<[MatchModel], DomainError>){
        loading = false
        switch result{
        case .success(let matches):
            self.matches = matches
            return
        case .failure(_):
            return
        }
    }
    
    
    private func performOnAppear(){
        firestoreViewModel.fetchMatches(onCompletion: onReceiveMatches)
    }
}

struct MatchListView_Previews: PreviewProvider {
    static var previews: some View {
        MatchListView()
            .environmentObject(FirestoreViewModel())
    }
}
