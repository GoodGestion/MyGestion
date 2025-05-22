import Foundation
import Combine

final class SignUpViewModel: ObservableObject {
    // — Inputs du formulaire
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var role: String = "independent"

    // — État UI
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didRegister = false

    // ← Nouveau flag pour l’alerte « email existant »
    @Published var showEmailExistsAlert = false

    private var cancellables = Set<AnyCancellable>()

    func register() {
        // 1) Validation basique
        guard !email.isEmpty,
              !password.isEmpty,
              password == confirmPassword
        else {
            errorMessage = "Veuillez remplir tous les champs correctement."
            return
        }

        // 2) Vérifier en mock si l’email existe déjà
        let defaults = UserDefaults.standard
        var users: [AppUser] = []
        if let data = defaults.data(forKey: "mockUsers"),
           let decoded = try? JSONDecoder().decode([AppUser].self, from: data) {
            users = decoded
        }
        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            // on déclenche l’alerte au lieu du login
            showEmailExistsAlert = true
            return
        }

        // 3) Si OK, on lance l’inscription mockée
        isLoading = true
        AuthService.shared
            .register(email: email, password: password, role: role)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                self.didRegister = true
            }
            .store(in: &cancellables)
    }
}
