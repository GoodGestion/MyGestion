// ViewModels/ProfileViewModel.swift
import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    @Published var experiences:    [Experience]   = []
    @Published var sector:         String         = ""
    @Published var availabilities: [Availability] = []

    @Published var isLoading    = false
    @Published var errorMessage: String?
    @Published var didSave      = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadProfile()
    }

    func saveProfile(token: String) {
        let profile = IndependentProfile(
            id:             UUID(),          // si tu enregistres localement
            email:          "",              // inutilisé ici pour le mock
            role:           "",
            firstName:      "",
            lastName:       "",
            phoneNumber:    "",
            siret:          "",
            sector:         sector,
            location:       "",              // idem
            experiences:    experiences,
            availabilities: availabilities
        )
        isLoading = true
        errorMessage = nil

        #if DEBUG
        let publisher = UserService.shared.saveProfileMock(profile, token: token)
        #else
        let publisher = UserService.shared.saveProfile(profile, token: token)
        #endif

        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                UserDefaults.standard.set(true, forKey: "hasProfile")
                if let data = try? JSONEncoder().encode(profile) {
                    UserDefaults.standard.set(data, forKey: "userProfile")
                }
                self.didSave = true
            }
            .store(in: &cancellables)
    }

    private func loadProfile() {
        let defaults = UserDefaults.standard
        guard
            let data  = defaults.data(forKey: "userProfile"),
            let saved = try? JSONDecoder().decode(IndependentProfile.self, from: data)
        else { return }
        experiences    = saved.experiences
        sector         = saved.sector
        availabilities = saved.availabilities
    }
}
