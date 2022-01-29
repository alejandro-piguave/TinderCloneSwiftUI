//
//  SwipeCardView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 1/1/22.
//

import SwiftUI

struct SwipeCardView: View {
    let model: UserProfile
    
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom){
            GeometryReader{ geometry in
                Image(uiImage: model.pictures[currentImageIndex])
                    .centerCropped()
                    .gesture(DragGesture(minimumDistance: 0).onEnded({ value in
                        if value.translation.equalTo(.zero){
                            if(value.location.x <= geometry.size.width/2){
                                showPrevPicture()
                            } else { showNextPicture()}
                        }
                    }))
            }
            
            VStack{
                if(model.pictures.count > 1){
                    HStack{
                        ForEach(0..<model.pictures.count, id: \.self){ index in
                            Rectangle().frame(height: 3).foregroundColor(index == currentImageIndex ? .white : .gray).opacity(index == currentImageIndex ? 1 : 0.5)
                        }
                    }
                    .padding(.top, 6)
                    .padding(.leading)
                    .padding(.trailing)
                }
                Spacer()
                VStack{
                    HStack(alignment: .firstTextBaseline){
                        Text(model.name).font(.largeTitle).fontWeight(.semibold)
                        Text("\(model.age)").font(.title).fontWeight(.medium)
                        Spacer()
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(0.7, contentMode: .fit)
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
    
    
    private func showNextPicture(){
        if currentImageIndex < model.pictures.count - 1 {
            currentImageIndex += 1
        }
    }
    
    private func showPrevPicture(){
        if currentImageIndex > 0 {
            currentImageIndex -= 1
        }
    }
}

struct SwipeCardView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCardView(model: UserProfile(userId: "defdwsfewfes", name: "Michael Jackson", age: 50, pictures: [UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!]))
    }
}
