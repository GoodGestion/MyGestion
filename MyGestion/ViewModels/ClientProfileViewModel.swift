// ViewModels/ClientProfileViewModel.swift
import Foundation
import Combine

final class ClientProfileViewModel: ObservableObject {
    // MARK: – Published properties
    @Published var sector      = ""
    @Published var location    = ""
    @Published var firstName   = ""
    @Published var lastName    = ""
    @Published var phoneNumber = ""
    @Published var siret       = ""

    @Published var isLoading    = false
    @Published var errorMessage: String?
    @Published var didSave      = false

    private var cancellables = Set<AnyCancellable>()

    /// Charge depuis UserDefaults le dernier profil mocké
    func loadMockProfile(for email: String) {
        let key = "mockClientProfile_\(email.lowercased())"
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key),
           let profile = try? JSONDecoder().decode(ClientProfile.self, from: data) {
            sector      = profile.sector
            location    = profile.location
            firstName   = profile.firstName
            lastName    = profile.lastName
            phoneNumber = profile.phoneNumber
            siret       = profile.siret
        }
    }

    /// Sauve en mock le profil complet dans UserDefaults
    func saveProfile(token: String, email: String, role: String) {
        isLoading    = true
        errorMessage = nil

        // Simule un délai de 1 seconde
        Just(())
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isLoading = false

                // Construction de l'objet ClientProfile
                let profile = ClientProfile(
                    email:       email.lowercased(),
                    role:        role,
                    sector:      self.sector,
                    location:    self.location,
                    firstName:   self.firstName,
                    lastName:    self.lastName,
                    phoneNumber: self.phoneNumber,
                    siret:       self.siret
                )

                let defaults = UserDefaults.standard
                let key = "mockClientProfile_\(email.lowercased())"
                do {
                    let data = try JSONEncoder().encode(profile)
                    defaults.set(data, forKey: key)
                    defaults.synchronize()

                    // Signale la réussite et réinitialise rapidement le flag
                    self.didSave = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.didSave = false
                    }
                } catch {
                    self.errorMessage = "Impossible d'enregistrer le profil."
                }
            }
            .store(in: &cancellables)
    }
}
