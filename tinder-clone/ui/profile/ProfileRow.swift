//
//  ProfileRow.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 12/1/22.
//

import SwiftUI

struct ProfileRow<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        HStack(content: content)
            .frame(minHeight: 40)
            .padding(.leading)
            .padding(.trailing)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .border(Color(UIColor.systemGray4), width: 0.5)
    }
}

struct ProfileRow_Previews: PreviewProvider {
    static var previews: some View {
        ProfileRow{}
    }
}
