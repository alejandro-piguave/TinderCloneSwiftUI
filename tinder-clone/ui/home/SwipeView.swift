//
//  SwipeView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 1/1/22.
//

import SwiftUI

enum SwipeAction{
    case swipeLeft, swipeRight, doNothing
}

struct SwipeView: View {
    
    @Binding var profiles: [UserProfile]
    @State var swipeAction: SwipeAction = .doNothing
    //Bool: true if it was a like (swipe to the right
    var onSwiped: (UserProfile, Bool) -> ()
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                ZStack{
                    Text("no-more-profiles").font(.title3).fontWeight(.medium).foregroundColor(Color(UIColor.systemGray)).multilineTextAlignment(.center)
                    ForEach(profiles.indices, id: \.self){ index  in
                        let model: UserProfile = profiles[index]
                        
                        if(index == profiles.count - 1){
                            SwipeableCardView(model: model, swipeAction: $swipeAction, onSwiped: performSwipe)
                        } else if(index == profiles.count - 2){
                            SwipeCardView(model: model)
                        }
                    }
                }
            }.padding()
            Spacer()
            HStack{
                Spacer()
                GradientOutlineButton(action:{swipeAction = .swipeLeft}, iconName: "multiply", colors: AppColor.dislikeColors)
                Spacer()
                GradientOutlineButton(action: {swipeAction = .swipeRight}, iconName: "heart", colors: AppColor.likeColors)
                Spacer()
            }.padding(.bottom)
        }
    }
    
    private func performSwipe(userProfile: UserProfile, hasLiked: Bool){
        removeTopItem()
        onSwiped(userProfile, hasLiked)
    }
    
    private func removeTopItem(){
        profiles.removeLast()
    }
    
    
}

struct SwipeView_Previews: PreviewProvider {
    @State static private var profiles: [UserProfile] = [
        UserProfile(userId: "defdwsfewfes", name: "Michael Jackson", age: 50, pictures: [UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!]),
        UserProfile(userId: "defdwsfewfes", name: "Michael Jackson", age: 50, pictures: [UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!,UIImage(named: "elon_musk")!,UIImage(named: "jeff_bezos")!])
    ]
    static var previews: some View {
        SwipeView(profiles: $profiles, onSwiped: {_,_ in})
    }
}
