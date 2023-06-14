//
//  ProfileView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 2/1/22.
//

import SwiftUI

struct ProfileInformation {
    var bio: String
    var gender: String
    var orientation: Orientation
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var editProfileViewModel = EditProfileViewModel()
    @EnvironmentObject var contentViewModel: ContentViewModel

    private let dateFormat = "MMM d, yyyy"
    @State private var initialProfile: ProfileInformation = ProfileInformation(bio: "", gender: "", orientation: .both)

    @State private var userName: String = ""
    @State private var userBirthdate: String = ""
    @State private var userBio: String = ""
    @State private var userGender: String = ""
    @State private var userOrientation: Orientation? = nil

    @State private var showContentTypeSheet: Bool = false
    @State private var showError: Bool = false
    @State private var showRemoveConfirmation: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showPermissionDenied: Bool = false
    @State private var showSignOutConfirmation: Bool = false

    @State private var confirmRemoveImageIndex: Int = 0
    @State private var selectedContentType: UIImagePickerController.SourceType = .photoLibrary
    @State private var pictures: [PictureModel] = []
    @State private var image = UIImage()
    @State private var droppedOutside: Bool = false
    @State private var picturesModified: Bool = false
    @State private var previousPicCount: Int = 0

    var body: some View {
        ProfileForm {
            PictureGridView(pictures: $pictures, picturesChanged: $picturesModified, droppedOutside: $droppedOutside, onAddedImageClick: { index in
                confirmRemoveImageIndex = index
                showRemoveConfirmation.toggle()
            }, onAddImageClick: {
                showContentTypeSheet.toggle()
            })
                    .padding(.leading).padding(.trailing)

            ProfileSection("about-you") {
                ProfileRow {
                    ProfileTextEditor($userBio)
                }
            }

            ProfileSection("gender") {
                ProfileRow {
                    Picker("", selection: $userGender) {
                        ForEach(Constants.genderOptions, id: \.self) {
                            Text(LocalizedStringKey($0))
                        }
                    }
                            .pickerStyle(.segmented).frame(maxWidth: .infinity)
                }
            }

            ProfileSection("i-am-interested-in") {
                ProfileRow {
                    Picker("", selection: $userOrientation) {
                        ForEach(Orientation.allCases, id: \.self) {
                            Text(LocalizedStringKey($0.rawValue)).tag($0 as Orientation?)
                        }
                    }
                            .pickerStyle(.segmented).frame(maxWidth: .infinity)
                }
            }

            ProfileSection("personal-info") {
                ProfileRow {
                    ProfileLabel(title: "name", systemName: "person.circle")
                    Spacer()
                    Text(userName)
                }
                ProfileRow {
                    ProfileLabel(title: "birthdate", systemName: "calendar")
                    Spacer()
                    Text(userBirthdate)
                }
            }

            Button(action: {
                self.showSignOutConfirmation.toggle()
            }, label: {
                Text("sign-out")
            })
                    .frame(maxWidth: .infinity).padding()
        }
                .navigationTitle("edit-profile")
                .toolbar {
                    Button("done", action: done)
                }
                .showLoading(editProfileViewModel.isLoading)
                .sheet(isPresented: $showContentTypeSheet) {
                    ContentTypeView(onContentTypeSelected: { contentType in
                        switch contentType {
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
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(sourceType: selectedContentType, selectedImage: $image)
                }
                .onAppear(perform: editProfileViewModel.fetchProfile)
                .onChange(of: editProfileViewModel.error, perform: { _ in
                    self.showError = true
                })
                .onChange(of: editProfileViewModel.userProfile, perform: { newValue in
                    if let user = newValue {
                        populateData(user)
                    }
                })
                .onChange(of: editProfileViewModel.userPictures, perform: { newValue in
                    pictures = newValue
                    previousPicCount = newValue.count
                })
                .onChange(of: editProfileViewModel.isProfileUpdated, perform: { newValue in
                    if (newValue) {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
                .onChange(of: image, perform: { newValue in
                    pictures.append(PictureModel.newPicture(newValue))
                    picturesModified = true
                })
                .alert("sign-out-confirmation", isPresented: $showSignOutConfirmation, actions: {
                    Button("yes", action: signOut)
                    Button("cancel", role: .cancel, action: {})
                })
                .alert("Error",
                        isPresented: $showError,
                        actions: {},
                        message: { Text(editProfileViewModel.error) })
                .alert("remove-confirmation", isPresented: $showRemoveConfirmation, actions: {
                    Button("yes", action: removePicture)
                    Button("cancel", role: .cancel, action: {})
                })
    }

    private func populateData(_ user: FirestoreUser) {
        userBio = user.bio
        userName = user.name
        userBirthdate = user.birthDate.getFormattedDate(format: dateFormat)
        userGender = Constants.genderOptions[user.isMale ? 0 : 1]
        userOrientation = user.orientation

        self.initialProfile.bio = userBio
        self.initialProfile.gender = userGender
        self.initialProfile.orientation = user.orientation
    }

    private func hasModifiedProfileInformation() -> Bool {
        initialProfile.bio != userBio || initialProfile.gender != userGender || initialProfile.orientation != userOrientation!
    }

    private func getModifiedProfileFields() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if (initialProfile.bio != userBio) {
            dictionary[FirestoreUser.CodingKeys.bio.rawValue] = userBio
        }
        if (initialProfile.gender != userGender) {
            dictionary[FirestoreUser.CodingKeys.isMale.rawValue] = Constants.genderOptions.firstIndex(of: userGender) == 0
        }
        if (initialProfile.orientation != userOrientation!) {
            dictionary[FirestoreUser.CodingKeys.orientation.rawValue] = userOrientation!.rawValue
        }
        return dictionary
    }

    private func done() {
        if (hasModifiedProfileInformation() && picturesModified) {
            editProfileViewModel.updateProfile(newPictures: pictures, modified: getModifiedProfileFields())
        } else if (hasModifiedProfileInformation()) {
            editProfileViewModel.updateProfile(modified: getModifiedProfileFields())
        } else if (picturesModified) {
            editProfileViewModel.updateProfile(newPictures: pictures)
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func removePicture() {
        if pictures.count <= 2 {
            showError = true
        } else {
            pictures.remove(at: confirmRemoveImageIndex)
            picturesModified = true
        }
    }

    private func signOut() {
        contentViewModel.signOut()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
