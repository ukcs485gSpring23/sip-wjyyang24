//
//  ProfileView.swift
//  OCKSample
//
//  Created by Corey Baker on 11/24/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//
import SwiftUI
import CareKitUI
import CareKitStore
import CareKit
import os.log

struct ProfileView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(\.tintColor) private var tintColor
    @StateObject var viewModel = ProfileViewModel()
    @ObservedObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    ProfileImageView(viewModel: viewModel)
                    Form {
                        Section(header: Text("About")) {
                            TextField("First Name", text: $viewModel.firstName)
                            TextField("Last Name", text: $viewModel.lastName)
                            DatePicker("Birthday",
                                       selection: $viewModel.birthday,
                                       displayedComponents: [DatePickerComponents.date])
                            Picker(selection: $viewModel.sex,
                                   label: Text("Sex")) {
                                Text(OCKBiologicalSex.female.rawValue).tag(OCKBiologicalSex.female)
                                Text(OCKBiologicalSex.male.rawValue).tag(OCKBiologicalSex.male)
                                Text(viewModel.sex.rawValue)
                                    .tag(OCKBiologicalSex.other(viewModel.sexOtherField))
                            }
                            TextField("Allergies", text: $viewModel.allergies)
                        }
                        Section(header: Text("Contact")) {
                            TextField("Email", text: $viewModel.email)
                            TextField("Messaging Number", text: $viewModel.messagingNumber)
                            TextField("Phone Number", text: $viewModel.phoneNumber)
                            TextField("Street", text: $viewModel.street)
                            TextField("City", text: $viewModel.city)
                            TextField("State", text: $viewModel.state)
                            TextField("Postal code", text: $viewModel.zipcode)
                            TextField("Other Contact Info", text: $viewModel.otherContactInfo)
                        }
                    }
                }

                Button(action: {
                    Task {
                        await viewModel.saveProfile()
                    }
                }, label: {
                    Text("Save Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                })
                .background(Color(tintColor))
                .cornerRadius(15)

                // Notice that "action" is a closure (which is essentially
                // a function as argument like we discussed in class)
                Button(action: {
                    Task {
                        await loginViewModel.logout()
                    }
                }, label: {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                })
                .background(Color(.red))
                .cornerRadius(15)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("My Contact") {
                            viewModel.isPresentingContact = true
                        }
                        .sheet(isPresented: $viewModel.isPresentingContact) {
                            MyContactView()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add Task") {
                            viewModel.isPresentingAddTask = true
                        }
                        .sheet(isPresented: $viewModel.isPresentingAddTask) {
                            CareKitTaskView()
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresentingImagePicker) {
                ImagePicker(image: $viewModel.profileUIImage)
            }
            .alert(isPresented: $viewModel.isShowingSaveAlert) {
                return Alert(title: Text("Update"),
                             message: Text(viewModel.alertMessage),
                             dismissButton: .default(Text("Ok"), action: {
                                viewModel.isShowingSaveAlert = false
                             }))
            }
        }
        .onReceive(appDelegate.$isFirstTimeLogin) { _ in
            viewModel.updateStoreManager()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init(storeManager: Utility.createPreviewStoreManager()),
                    loginViewModel: .init())
            .accentColor(Color(TintColorKey.defaultValue))
    }
}
