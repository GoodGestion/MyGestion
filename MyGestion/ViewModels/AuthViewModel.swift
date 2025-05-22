// ViewModels/AuthViewModel.swift
import Foundation
import Combine

/// Gère l’état de connexion / rôle / session / profils complétés
final class AuthViewModel: ObservableObject {
    // MARK: – Published properties (UI)
    @Published var isLoggedIn              = false
    @Published var role: String?           = nil
    @Published var email: String           = ""
    @Published var isLoading               = false
    @Published var errorMessage: String?

    /// Flags “profil complété” pour chaque type d’utilisateur
    @Published var hasIndependentProfile   = false
    @Published var hasClientProfile        = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: – Init / session restore
    init() {
        // Si on a déjà un JWT + email stocké → on restaure l’état
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "jwt"),
           !token.isEmpty,
           let savedEmail = defaults.string(forKey: "userEmail") {
            self.email = savedEmail
            self.loadProfilesFlags()
            self.validateSession()
        }
    }

    // MARK: – Login
    func login(email: String, password: String) {
        isLoading    = true
        errorMessage = nil

        AuthService.shared
            .login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] resp in
                guard let self = self else { return }
                self.email       = email
                self.role        = resp.role.lowercased()
                self.isLoggedIn  = true

                // On sauvegarde le token et l’email
                let defaults = UserDefaults.standard
                defaults.set(resp.token, forKey: "jwt")
                defaults.set(email,        forKey: "userEmail")

                // On recharge nos flags de profil complété
                self.loadProfilesFlags()
            }
            .store(in: &cancellables)
    }

    // MARK: – Silent token validation
    private func validateSession() {
        AuthService.shared
            .validateToken()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.logout()
                }
            } receiveValue: { [weak self] resp in
                guard let self = self else { return }
                self.role       = resp.role.lowercased()
                self.isLoggedIn = true
                self.loadProfilesFlags()
            }
            .store(in: &cancellables)
    }

    // MARK: – Logout
    func logout() {
        isLoggedIn              = false
        role                    = nil
        email                   = ""
        hasIndependentProfile   = false
        hasClientProfile        = false

        // On ne supprime plus mockHasProfile / mockHasClientProfile,
            // pour garder en mémoire que le profil a bien été complété.
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "jwt")
            defaults.removeObject(forKey: "userEmail")
            // <-- plus de suppression de "mockHasProfile" / "mockHasClientProfile"
        }

    // MARK: – Gestion des flags en UserDefaults
    private func loadProfilesFlags() {
        let defaults = UserDefaults.standard

        let dictI = defaults
            .dictionary(forKey: "mockHasProfile") as? [String:Bool] ?? [:]
        let dictC = defaults
            .dictionary(forKey: "mockHasClientProfile") as? [String:Bool] ?? [:]

        let key = email.lowercased()
        hasIndependentProfile = dictI[key] ?? false
        hasClientProfile      = dictC[key] ?? false
    }

    /// À appeler après avoir bien sauvegardé le profil indépendant
    func setIndependentProfile(_ done: Bool) {
        var dict = UserDefaults.standard
            .dictionary(forKey: "mockHasProfile") as? [String:Bool] ?? [:]
        dict[email.lowercased()] = done
        UserDefaults.standard.set(dict, forKey: "mockHasProfile")
        hasIndependentProfile = done
    }

    /// À appeler après avoir bien sauvegardé le profil client
    func setClientProfile(_ done: Bool) {
        var dict = UserDefaults.standard
            .dictionary(forKey: "mockHasClientProfile") as? [String:Bool] ?? [:]
        dict[email.lowercased()] = done
        UserDefaults.standard.set(dict, forKey: "mockHasClientProfile")
        hasClientProfile = done
    }
}
