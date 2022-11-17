//
//  InititalConfigurationView.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 2/1/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct CreateProfileView: View {
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var datePickerSelection: Date = Date()
    @State private var genderSelection: String = ""
    @State private var orientationSelection: Orientation? = nil
    @State private var pictures: [ProfilePicture] = []
    @State private var image = UIImage()
    @State private var selectedContentType: UIImagePickerController.SourceType = .photoLibrary

    @State private var showImagePicker: Bool = false
    @State private var showContentTypeSheet: Bool = false
    @State private var showError: Bool = false
    @State private var showRemoveConfirmation: Bool = false
    @State private var showPermissionDenied: Bool = false

    @State private var confirmRemoveImageIndex: Int = 0
    @State private var droppedOutside: Bool = false

    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject private var createProfileViewModel = CreateProfileViewModel()

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var partialRange: PartialRangeThrough<Date> {
        let eighteenYearsAgo = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        return ...eighteenYearsAgo
    }
    var body: some View {
        ProfileForm {
            PictureGridView(pictures: $pictures, droppedOutside: $droppedOutside, onAddedImageClick: { index in
                confirmRemoveImageIndex = index
                showRemoveConfirmation.toggle()
            }, onAddImageClick: {
                showContentTypeSheet.toggle()
            })
                    .padding(.leading).padding(.trailing)

            ProfileSection("personal-info") {
                ProfileRow {
                    TextField("enter-your-name", text: $userName)
                }
                ProfileRow {
                    DatePicker(selection: $datePickerSelection, in: partialRange, displayedComponents: .date, label: { Text("pick-your-birthday") })
                }
            }

            ProfileSection("about-you") {
                ProfileRow {
                    ProfileTextEditor($userBio)
                }
            }

            ProfileSection("gender") {
                ProfileRow {
                    Picker("", selection: $genderSelection) {
                        ForEach(Constants.genderOptions, id: \.self) {
                            Text(LocalizedStringKey($0)).tag($0)
                        }
                    }
                            .pickerStyle(.segmented).frame(maxWidth: .infinity)
                }
            }

            ProfileSection("i-am-interested-in") {
                ProfileRow {
                    Picker("", selection: $orientationSelection) {
                        ForEach(Orientation.allCases, id: \.self) {
                            Text(LocalizedStringKey($0.rawValue)).tag($0 as Orientation?)
                        }
                    }
                            .pickerStyle(.segmented).frame(maxWidth: .infinity)
                }
            }

            Button {
                submitInformation()
            } label: {
                HStack {
                    Image("icons8-google-48")
                            .resizable()
                            .frame(width: 24, height: 24)

                    Text("Create account with Google")
                }
            }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .disabled(isInformationValid())

        }
                .background(AppColor.lighterGray)
                .navigationBarTitle("create-profile")
                .showLoading(createProfileViewModel.isLoading)
                .onDrop(of: [UTType.text], delegate: DropOutsideDelegate(droppedOutside: $droppedOutside))
                .onChange(of: createProfileViewModel.signUpError, perform: { _ in
                    showError = true
                })
                .onChange(of: image, perform: { newValue in
                    pictures.append(ProfilePicture(filename: nil, picture: newValue))
                })
                .onChange(of: createProfileViewModel.isSignUpComplete) { newValue in
                    if newValue {
                        self.presentationMode.wrappedValue.dismiss()
                        contentViewModel.updateAuthState()
                    }
                }
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
                .alert("camera-permission-denied", isPresented: $showPermissionDenied, actions: {}, message: { Text("user-must-grant-camera-permission") })

                .alert("Error",
                        isPresented: $showError,
                        actions: {},
                        message: {
                            Text(createProfileViewModel.signUpError ?? "")
                        })
                .alert("Remove this picture?", isPresented: $showRemoveConfirmation, actions: {
                    Button("Yes", action: removePicture)
                    Button("Cancel", role: .cancel, action: {})
                })
    }

    private func removePicture() {
        pictures.remove(at: confirmRemoveImageIndex)
    }

    private func isInformationValid() -> Bool {
        return userName.count < 2 || userName.count > 30 ||
                !CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: userName)) || genderSelection.isEmpty || orientationSelection == nil
                || pictures.count < 2
    }

    private func submitInformation() {
        let profileData = ProfileData(name: userName, birthDate: datePickerSelection, bio: userBio, isMale: Constants.genderOptions.firstIndex(of: genderSelection) == 0, orientation: .both,
                pictures: pictures.map({ $0.picture }))
        createProfileViewModel.signUp(profileData: profileData, controller: getRootViewController())
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProfileView()
    }
}
