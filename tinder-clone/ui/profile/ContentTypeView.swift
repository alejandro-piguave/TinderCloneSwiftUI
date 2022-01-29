//
//  ContentTypeSheetView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 3/1/22.
//

import SwiftUI
import AVFoundation

enum ContentResult{
    case contentType(UIImagePickerController.SourceType)
    case permissionDenied
}

struct ContentTypeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let onContentTypeSelected: (ContentResult) -> ()
    var body: some View {
        VStack(alignment:.leading){
            Button{
               presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "multiply").resizable().frame(width: 24, height: 24).foregroundColor(.gray).padding(.bottom)
            }
            
            Text("create-new").font(.largeTitle).bold()
            Text("select-content-type").font(.caption).fontWeight(.light)
            Spacer()

            Button{
                presentationMode.wrappedValue.dismiss()
                onContentTypeSelected(.contentType(.photoLibrary))
            } label: {
                ZStack(alignment: .bottomTrailing){
                    HStack{
                        VStack(alignment: .leading){
                            Text("upload").font(.caption).fontWeight(.light)
                            Text("photo").font(.title2).bold()
                        }
                        Spacer()
                    }
                    .padding(30)
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .rotationEffect(Angle(degrees: -20))
                        .offset(x: 10,y: 10)
                        .opacity(0.8)
                    
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: .init(colors: AppColor.appColors),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing))
                .cornerRadius(12)
            }
            Button{
                checkCameraPermissionStatus()
            } label: {
                ZStack(alignment: .bottomTrailing){
                    HStack{
                        VStack(alignment: .leading){
                            Text("capture-from").font(.caption).fontWeight(.light)
                            Text("camera").font(.title2).bold()
                        }
                        Spacer()
                    }.padding(30)
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .rotationEffect(Angle(degrees: -20))
                        .offset(x: 10,y: 10)
                        .opacity(0.8)
                }.foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: .init(colors: AppColor.purpleColors),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing))
                    .cornerRadius(12)

            }
            Spacer()
        }.frame(maxWidth: .infinity).padding(.leading).padding(.trailing).padding(.top, 32)
    }
    
    private func checkCameraPermissionStatus(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            requestPremissions()
            return
        case .denied:
            presentationMode.wrappedValue.dismiss()
            onContentTypeSelected(.permissionDenied)
            return
        case .authorized:
            presentationMode.wrappedValue.dismiss()
            onContentTypeSelected(.contentType(.camera))
            return
        default: return
        }
    }
    
    private func requestPremissions(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
            if(granted){
                presentationMode.wrappedValue.dismiss()
                onContentTypeSelected(.contentType(.camera))
            } else{
                presentationMode.wrappedValue.dismiss()
                onContentTypeSelected(.permissionDenied)
            }
        })
    }
}

struct ContentTypeSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ContentTypeView(onContentTypeSelected: {_ in})
    }
}
