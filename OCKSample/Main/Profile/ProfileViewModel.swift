//
//  ProfileViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 11/25/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//
import Foundation
import CareKit
import CareKitStore
import CareKitUtilities
import SwiftUI
import ParseCareKit
import os.log
import Combine
import ParseSwift

class ProfileViewModel: ObservableObject {
    // MARK: Public read, private write properties
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var birthday = Date()
    @Published var sex: OCKBiologicalSex = .other("other")
    @Published var allergies = ""
    @Published var sexOtherField = "other"
    @Published var note = ""
    @Published var email = ""
    @Published var messagingNumber = ""
    @Published var phoneNumber = ""
    @Published var otherContactInfo = ""
    @Published var street = ""
    @Published var city = ""
    @Published var state = ""
    @Published var zipcode = ""
    @Published var isShowingSaveAlert = false
    @Published var isPresentingAddTask = false
    @Published var isPresentingContact = false
    @Published var isPresentingImagePicker = false
    @Published var profileUIImage = UIImage(systemName: "person.fill") {
        willSet {
            guard self.profileUIImage != newValue,
                let inputImage = newValue else {
                return
            }

            if !isSettingProfilePictureForFirstTime {
                Task {
                    guard var currentUser = (try? await User.current()),
                          let image = inputImage.jpegData(compressionQuality: 0.25) else {
                        Logger.profile.error("User is not logged in or could not compress image")
                        return
                    }

                    let newProfilePicture = ParseFile(name: "profile.jpg", data: image)
                    // Use `.set()` to update ParseObject's that have already been saved before.
                    currentUser = currentUser.set(\.profilePicture, to: newProfilePicture)
                    do {
                        _ = try await currentUser.save()
                        Logger.profile.info("Saved updated profile picture successfully.")
                    } catch {
                        Logger.profile.error("Could not save profile picture: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    @Published private(set) var error: Error?

    @Published var patient: OCKPatient? {
        willSet {
            if let currentFirstName = newValue?.name.givenName {
                firstName = currentFirstName
            } else {
                firstName = ""
            }
            if let currentLastName = newValue?.name.familyName {
                lastName = currentLastName
            } else {
                lastName = ""
            }
            if let currentBirthday = newValue?.birthday {
                birthday = currentBirthday
            } else {
                birthday = Date()
            }
            if let currentAllergies = newValue?.allergies {
                allergies = currentAllergies[0]
            } else {
                allergies = ""
            }
        }
    }
    private var contact: OCKContact?
    private(set) var storeManager: OCKSynchronizedStoreManager {
        didSet {
            reloadViewModel()
        }
    }
    private(set) var alertMessage = "All changs saved successfully!"

    // MARK: Private read/write properties
    private var isSettingProfilePictureForFirstTime = true
    private var cancellables: Set<AnyCancellable> = []

    init(storeManager: OCKSynchronizedStoreManager? = nil) {
        self.storeManager = storeManager ?? StoreManagerKey.defaultValue
        reloadViewModel()
    }

    // MARK: Helpers (public)

    func updateStoreManager() {
        self.storeManager = StoreManagerKey.defaultValue
    }

    // MARK: Helpers (private)
    private func clearSubscriptions() {
        cancellables = []
    }

    private func reloadViewModel() {
        Task {
            _ = await findAndObserveCurrentProfile()
        }
    }

    @MainActor
    private func findAndObserveCurrentProfile() async {
        guard let uuid = (try? await Utility.getRemoteClockUUID()) else {
            Logger.profile.error("Could not get remote uuid for this user.")
            return
        }
        clearSubscriptions()

        do {
            try await fetchProfilePicture()
        } catch {
            Logger.profile.error("Could not fetch profile image: \(error)")
        }

        // Build query to search for OCKPatient
        // swiftlint:disable:next line_length
        var queryForCurrentPatient = OCKPatientQuery(for: Date()) // This makes the query for the current version of Patient
        queryForCurrentPatient.ids = [uuid.uuidString] // Search for the current logged in user

        do {
            let foundPatient = try await storeManager.store.fetchAnyPatients(query: queryForCurrentPatient)
            guard let currentPatient = foundPatient.first as? OCKPatient else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observePatient(currentPatient)

            // Query the contact also so the user can edit
            var queryForCurrentContact = OCKContactQuery(for: Date())
            queryForCurrentContact.ids = [uuid.uuidString]
            let foundContact = try await storeManager.store.fetchAnyContacts(query: queryForCurrentContact)
            guard let currentContact = foundContact.first as? OCKContact else {
                // swiftlint:disable:next line_length
                Logger.profile.error("Error: Could not find contact with id \"\(uuid)\". It's possible they have never been saved.")
                return
            }
            self.observeContact(currentContact)
        } catch {
            // swiftlint:disable:next line_length
            Logger.profile.error("Could not find patient with id \"\(uuid)\". It's possible they have never been saved. Query error: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func observePatient(_ patient: OCKPatient) {
        storeManager.publisher(forPatient: patient,
                               categories: [.add, .update, .delete])
            .sink { [weak self] in
                self?.patient = $0 as? OCKPatient
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func observeContact(_ contact: OCKContact) {

        storeManager.publisher(forContact: contact,
                               categories: [.add, .update, .delete])
            .sink { [weak self] in
                self?.contact = $0 as? OCKContact
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func fetchProfilePicture() async throws {

         // Profile pics are stored in Parse User.
        guard let currentUser = (try? await User.current().fetch()) else {
            Logger.profile.error("User is not logged in")
            return
        }

        if let pictureFile = currentUser.profilePicture {

            // Download picture from server if needed
            do {
                let profilePicture = try await pictureFile.fetch()
                guard let path = profilePicture.localURL?.relativePath else {
                    Logger.profile.error("Could not find relative path for profile picture.")
                    return
                }
                self.profileUIImage = UIImage(contentsOfFile: path)
            } catch {
                Logger.profile.error("Could not fetch profile picture: \(error.localizedDescription).")
            }
        }
        self.isSettingProfilePictureForFirstTime = false
    }
}

// MARK: User intentional behavior
extension ProfileViewModel {
    @MainActor
    func saveProfile() async {
        alertMessage = "All changs saved successfully!"
        do {
            try await savePatient()
            try await saveContact()
        } catch {
            alertMessage = "Could not save profile: \(error)"
        }
        isShowingSaveAlert = true // Make alert pop up for user.
    }

    @MainActor  // swiftlint:disable:next cyclomatic_complexity
    func savePatient() async throws {
        if var patientToUpdate = patient {
            // If there is a currentPatient that was fetched, check to see if any of the fields changed
            var patientHasBeenUpdated = false

            if patient?.name.givenName != firstName {
                patientHasBeenUpdated = true
                patientToUpdate.name.givenName = firstName
            }

            if patient?.name.familyName != lastName {
                patientHasBeenUpdated = true
                patientToUpdate.name.familyName = lastName
            }

            if patient?.birthday != birthday {
                patientHasBeenUpdated = true
                patientToUpdate.birthday = birthday
            }

            if patient?.sex != sex {
                patientHasBeenUpdated = true
                patientToUpdate.sex = sex
            }

            if patient?.allergies != [allergies] {
                patientHasBeenUpdated = true
                patientToUpdate.allergies = [allergies]
            }

            let notes = [OCKNote(author: firstName,
                                 title: "New Note",
                                 content: note)]
            if patient?.notes != notes {
                patientHasBeenUpdated = true
                patientToUpdate.notes = notes
            }

            if patientHasBeenUpdated {
                let updated = try await storeManager.store.updateAnyPatient(patientToUpdate)
                Logger.profile.info("Successfully updated patient")
                guard let updatedPatient = updated as? OCKPatient else {
                    Logger.profile.error("Could not cast to OCKPatient")
                    return
                }
                self.patient = updatedPatient
            }

        } else {
            guard let remoteUUID = (try? await Utility.getRemoteClockUUID())?.uuidString else {
                Logger.profile.error("The user currently is not logged in")
                return
            }

            var newPatient = OCKPatient(id: remoteUUID,
                                        givenName: firstName,
                                        familyName: lastName)
            newPatient.birthday = birthday

            // This is new patient that has never been saved before
            let addedPatient = try await storeManager.store.addAnyPatient(newPatient)
            Logger.profile.info("Succesffully saved new patient")
            guard let addedOCKPatient = addedPatient as? OCKPatient else {
                Logger.profile.error("Could not cast to OCKPatient")
                return
            }
            self.patient = addedOCKPatient
            self.observePatient(addedOCKPatient)
        }
    }

    @MainActor  // swiftlint:disable:next cyclomatic_complexity
    func saveContact() async throws {

        if var contactToUpdate = contact {
            // If a current contact was fetched, check to see if any of the fields have changed
            var contactHasBeenUpdated = false

            // Since OCKPatient was updated earlier, we should compare against this name
            if let patientName = patient?.name,
                contact?.name != patient?.name {
                contactHasBeenUpdated = true
                contactToUpdate.name = patientName
            }

            // Create a mutable temp address to compare
            let potentialAddress = OCKPostalAddress()
            potentialAddress.street = street
            potentialAddress.city = city
            potentialAddress.state = state
            potentialAddress.postalCode = zipcode

            if contact?.address != potentialAddress {
                contactHasBeenUpdated = true
                contactToUpdate.address = potentialAddress
            }

            let potentialEmail = OCKLabeledValue(label: "Home email", value: email)
            if contact?.emailAddresses != [potentialEmail] {
                contactHasBeenUpdated = true
                contactToUpdate.emailAddresses = [potentialEmail]
            }

            let potentialMessagingNumber = OCKLabeledValue(label: "Messaging Number", value: messagingNumber)
            if contact?.messagingNumbers != [potentialMessagingNumber] {
                contactHasBeenUpdated = true
                contactToUpdate.messagingNumbers = [potentialMessagingNumber]
            }

            let potentialPhoneNumber = OCKLabeledValue(label: "Phone Number", value: phoneNumber)
            if contact?.phoneNumbers != [potentialPhoneNumber] {
                contactHasBeenUpdated = true
                contactToUpdate.phoneNumbers = [potentialPhoneNumber]
            }

            let potentialOther = OCKLabeledValue(label: "Other", value: otherContactInfo)
            if contact?.otherContactInfo != [potentialOther] {
                contactHasBeenUpdated = true
                contactToUpdate.otherContactInfo = [potentialOther]
            }

            if contactHasBeenUpdated {
                let updated = try await storeManager.store.updateAnyContact(contactToUpdate)
                Logger.profile.info("Successfully updated contact")
                guard let updatedContact = updated as? OCKContact else {
                    Logger.profile.error("Could not cast to OCKContact")
                    return
                }
                self.contact = updatedContact
            }

        } else {

            guard let remoteUUID = (try? await Utility.getRemoteClockUUID())?.uuidString else {
                Logger.profile.error("The user currently is not logged in")
                return
            }

            guard let patientName = self.patient?.name else {
                Logger.profile.info("The patient did not have a name.")
                return
            }

            // Added code to create a contact for the respective signed up user
            let newContact = OCKContact(id: remoteUUID,
                                        name: patientName,
                                        carePlanUUID: nil)

            guard let addedContact = try await storeManager.store.addAnyContact(newContact) as? OCKContact else {
                Logger.profile.error("Could not cast to OCKContact")
                return
            }
            self.contact = addedContact
            self.observeContact(addedContact)
        }
    }
}
