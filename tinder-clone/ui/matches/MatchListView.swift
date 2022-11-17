//
//  ChatView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 2/1/22.
//

import SwiftUI

struct MatchListView: View {
    @StateObject private var matchListViewModel = MatchListViewModel()
    
    var body: some View {
        VStack{
            if(matchListViewModel.isLoading){
                ProgressView()
            }else {
                if(matchListViewModel.matchModels.isEmpty){
                    Text("no-matches-yet")
                } else {
                    List(matchListViewModel.matchModels){ item in
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

    private func performOnAppear(){
        if matchListViewModel.isFirstFetching{
            matchListViewModel.fetchMatches()
        }
    }
}

struct MatchListView_Previews: PreviewProvider {
    static var previews: some View {
        MatchListView()
    }
}
