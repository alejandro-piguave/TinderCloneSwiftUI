//
//  ProfileView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 2/1/22.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let dateFormat = "MMM d, yyyy"
    @State private var initialBio = ""
    @State private var initialGender = ""
    @State private var initialOrientation: Orientation = .both
    
    @State private var isLoading: Bool = false
    @State private var userName: String = ""
    @State private var userBirthdate: String = ""
    @State private var userBio: String = ""
    
    @State private var showContentTypeSheet: Bool = false
    @State private var showError: Bool = false
    @State private var showRemoveConfirmation: Bool = false
    @State private var showPicDeleteError: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showPermissionDenied: Bool = false
    
    @State private var confirmRemoveImageIndex: Int = 0
    @State private var selectedContentType: UIImagePickerController.SourceType = .photoLibrary
    @State private var pictures: [UIImage] = []
    @State private var image = UIImage()
    @State private var droppedOutside: Bool = false
    @State private var showSignOutConfirmation: Bool = false
    @State private var picturesModified: Bool = false
    @State private var previousPicCount: Int = 0
    @State private var genderSelection: String = ""
    @State private var orientationSelection: Orientation? = nil
    
    var body: some View {
        ProfileForm{
            PictureGridView(pictures: $pictures, picturesChanged: $picturesModified, droppedOutside: $droppedOutside, onAddedImageClick: { index in
                    confirmRemoveImageIndex = index
                    showRemoveConfirmation.toggle()
                }, onAddImageClick: {
                    showContentTypeSheet.toggle()
                }).padding(.leading).padding(.trailing)
            
            ProfileSection("about-you"){
                ProfileRow{
                    ProfileTextEditor($userBio)
                }
            }
            
            ProfileSection("gender"){
                ProfileRow{
                    Picker("", selection: $genderSelection) {
                        ForEach(Constants.genderOptions, id: \.self) {
                            Text(LocalizedStringKey($0))
                        }
                    }.pickerStyle(.segmented).frame(maxWidth: .infinity)
                }
            }
            
            ProfileSection("i-am-interested-in"){
                ProfileRow{
                    Picker("", selection: $orientationSelection) {
                        ForEach(Orientation.allCases, id: \.self) {
                            Text(LocalizedStringKey($0.rawValue)).tag($0 as Orientation?)
                        }
                    }.pickerStyle(.segmented).frame(maxWidth: .infinity)
                }
            }
            
            ProfileSection("personal-info"){
                ProfileRow{
                    ProfileLabel(title: "name", systemName: "person.circle" )
                    Spacer()
                    Text(userName)
                }
                ProfileRow{
                    ProfileLabel(title: "birthdate", systemName: "calendar")
                    Spacer()
                    Text(userBirthdate)
                }
            }
            
            Button(action: {
                self.showSignOutConfirmation.toggle()
            },label: {
                Text("sign-out")
            }).frame(maxWidth: .infinity).padding()
        }
        .showLoading(isLoading)
        .onChange(of: image, perform: {newValue in
            pictures.append(newValue)
            picturesModified = true
        })
        .sheet(isPresented: $showContentTypeSheet){
            ContentTypeView(onContentTypeSelected: { contentType in
                switch contentType{
                case .permissionDenied:
                    showPermissionDenied.toggle()
                    return
                case .contentType(let sourceType):
                    self.selectedContentType = sourceType
                    showImagePicker.toggle()
                    return
                }
            })
        }
        .sheet(isPresented: $showImagePicker){
            ImagePicker(sourceType: selectedContentType, selectedImage: $image)
        }
        .alert("pic-delete-error", isPresented: $showPicDeleteError, actions: {}, message: {Text("pic-delete-error-msg")})
        .alert("sign-out-confirmation", isPresented: $showSignOutConfirmation, actions: {
            Button("yes", action: signOut)
            Button("cancel", role: .cancel, action: {})
        })
        .alert("camera-permission-denied", isPresented: $showPermissionDenied, actions: {}, message: {Text("user-must-grant-camera-permission")})
        .alert("upload-error", isPresented: $showError, actions: {}, message: {Text("error-uploading-profile")})
        .alert("remove-confirmation", isPresented: $showRemoveConfirmation, actions: {
            Button("yes", action: removePicture)
            Button("cancel", role: .cancel, action: {})
        })
        .navigationTitle("edit-profile")
        .toolbar {
            Button("done", action: done)
        }
        .onAppear(perform: performOnAppear)
    }
    
    private func performOnAppear(){
        firestoreViewModel.fetchUserProfile{ result in
            switch(result){
            case .success(let user):
                populateData(user)
                return
            case .failure(_):
                self.showError = true
                return
                
            }
        }
        firestoreViewModel.fetchUserPictures(onCompletion: { result in
            switch result{
            case .success(let pictureList):
                pictures = pictureList
                previousPicCount = pictureList.count
                return
            case .failure(_):
                return
            }
        }, onUpdate: {result in
            switch result{
            case .success(let pictureList):
                pictures = pictureList
                previousPicCount = pictureList.count
                return
            case .failure(_):
                return
            }
        })
    }
    
    private func populateData(_ user: FirestoreUser){
        userBio = user.bio
        userName = user.name
        userBirthdate = user.birthDate.getFormattedDate(format: dateFormat)
        genderSelection = Constants.genderOptions[user.isMale ? 0 : 1]
        orientationSelection = user.orientation
        self.initialBio = userBio
        self.initialGender = genderSelection
        self.initialOrientation = user.orientation
    }
    
    private func onProfileUpdateCompletion(result: Result<Void, DomainError>){
        isLoading = false
        switch result{
        case .success(_):
            presentationMode.wrappedValue.dismiss()
            return
        case .failure(_):
            showError = true
            return
        }
    }
    
    private func hasModifiedProfileInformation() -> Bool{
        return initialBio != userBio || initialGender != genderSelection || initialOrientation != orientationSelection!
    }
    
    private func getModifiedProfileFields() -> [String: Any]{
        var dictionary: [String: Any] = [:]
        if(initialBio != userBio){ dictionary[FirestoreUser.CodingKeys.bio.rawValue] = userBio}
        if(initialGender != genderSelection){ dictionary[FirestoreUser.CodingKeys.isMale.rawValue] = Constants.genderOptions.firstIndex(of: genderSelection) == 0}
        if(initialOrientation != orientationSelection!){ dictionary[FirestoreUser.CodingKeys.orientation.rawValue] = orientationSelection!.rawValue}
        return dictionary
    }
    
    private func done(){
        isLoading = true
        if(hasModifiedProfileInformation() && picturesModified){
            firestoreViewModel.updateUserProfile(modified: getModifiedProfileFields(), pictures: pictures, previousPicCount: previousPicCount, onCompletion: onProfileUpdateCompletion)
        } else if(hasModifiedProfileInformation()){
            firestoreViewModel.updateUserProfile(modified: getModifiedProfileFields(), onCompletion: onProfileUpdateCompletion)
        } else if(picturesModified){
            firestoreViewModel.updateUserProfile(pictures: pictures, previousPicCount: previousPicCount, onCompletion: onProfileUpdateCompletion)
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func removePicture(){
        if pictures.count <= 2 {
            showPicDeleteError = true
        } else{
            pictures.remove(at: confirmRemoveImageIndex)
            picturesModified = true
        }
    }
    
    private func signOut(){
        authViewModel.signOut()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
