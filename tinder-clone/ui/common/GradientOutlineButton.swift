//
//  GradientOutlineButton.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 1/1/22.
//

import SwiftUI

struct GradientOutlineButton: View {
    
    let action: () -> ()
    let iconName: String
    let colors: [Color]
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: iconName).font(.system(size: 24, weight: .bold)).foregroundGradient(colors: colors)
                .padding()
                .overlay(Ellipse().stroke(LinearGradient(gradient: .init(colors: colors),
                                                         startPoint: .topLeading,
                                                         endPoint: .bottomTrailing), lineWidth: 3))
        })
    }
}

struct GradientOutlineButton_Previews: PreviewProvider {
    static var previews: some View {
        GradientOutlineButton(action: {
            print("It works!")
        },iconName: "heart", colors: [Color(red: 232/255, green: 57/255, blue: 132/255), Color(red: 244/255, green: 125/255, blue: 83/255)])
    }
}
