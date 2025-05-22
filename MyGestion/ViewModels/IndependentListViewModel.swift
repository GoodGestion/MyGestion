// ViewModels/IndependentListViewModel.swift
import Foundation
import Combine

/// Liste les IndependentProfile existants, tels que mockés dans UserDefaults
final class IndependentListViewModel: ObservableObject {
    @Published var independents: [IndependentProfile] = []

    private let adminVM = AdminViewModel()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // À chaque fois que adminVM.users change, on recharge les profils
        adminVM.$users
            .sink { [weak self] _ in
                self?.reloadProfiles()
            }
            .store(in: &cancellables)
    }

    /// Appelé pour rafraîchir la liste des independents
    func loadIndependents() {
        // 1) Récupère les users mockés
        adminVM.fetchAllUsers()
        // 2) adminVM.users va changer → notre subscriber appellera reloadProfiles()
    }

    /// Filtre les users indépendante et charge leurs profiles mockés
    private func reloadProfiles() {
        let indieEmails = adminVM.users
            .filter { $0.role.lowercased() == "independent" }
            .map { $0.email }

        var loaded: [IndependentProfile] = []
        let defaults = UserDefaults.standard

        for email in indieEmails {
            let key = "mockIndependentProfile_\(email)"
            if let data = defaults.data(forKey: key),
               let profile = try? JSONDecoder().decode(IndependentProfile.self, from: data) {
                loaded.append(profile)
            }
        }

        // Met à jour la liste publiée
        DispatchQueue.main.async {
            self.independents = loaded
        }
    }
}
