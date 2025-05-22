import Foundation
import Combine

final class PasswordResetViewModel: ObservableObject {
    @Published var email: String
    @Published var newPassword = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didReset = false

    init(email: String) {
        self.email = email
    }

    func resetPassword() {
        guard !newPassword.isEmpty, newPassword == confirmPassword else {
            errorMessage = "Les mots de passe ne correspondent pas."
            return
        }
        isLoading = true

        // Simule 1s de chargement
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            let defaults = UserDefaults.standard
            var users: [AppUser] = []
            if let data = defaults.data(forKey: "mockUsers"),
               let decoded = try? JSONDecoder().decode([AppUser].self, from: data) {
                users = decoded
            }
            guard let idx = users.firstIndex(where: { $0.email.lowercased() == self.email.lowercased() }) else {
                self.errorMessage = "Email non trouvé."
                self.isLoading = false
                return
            }
            users[idx].password = self.newPassword
            if let encoded = try? JSONEncoder().encode(users) {
                defaults.set(encoded, forKey: "mockUsers")
            }
            // met à jour aussi le dernier mockPassword si c’est le même email
            if defaults.string(forKey: "mockEmail")?.lowercased() == self.email.lowercased() {
                defaults.set(self.newPassword, forKey: "mockPassword")
            }
            self.isLoading = false
            self.didReset = true
        }
    }
}
