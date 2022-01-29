//
//  ProfileTextEditor.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 13/1/22.
//

import SwiftUI

struct ProfileTextEditor: View {
    private let charLimit: Int = 500
    init(_ text: Binding<String>){
        self._text = text
        UITextView.appearance().backgroundColor = .clear
    }
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            TextEditor(text: $text).background(colorScheme == .dark ? Color(UIColor.systemGray6) : .white).onChange(of: text, perform: {newValue in
                if(newValue.count >= charLimit){
                    text = String(newValue.prefix(charLimit))
                }
            })
            HStack{
                Spacer()
                Text("\(charLimit - text.count)").foregroundColor(.gray).font(.headline).bold()
            }
        }
    }
}

struct ProfileTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ProfileTextEditor(.constant("Texto de prueba para hacer la preview. "))
        }
    }
}
