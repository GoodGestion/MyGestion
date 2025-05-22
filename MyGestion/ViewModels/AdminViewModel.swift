import Foundation
import Combine

final class AdminViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    /// récupère depuis UserDefaults
    func fetchAllUsers() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "mockUsers"),
           let decoded = try? JSONDecoder().decode([AppUser].self, from: data) {
            self.users = decoded
        } else {
            self.users = []
        }
    }

    /// supprime en local et met à jour UserDefaults
    func delete(at offsets: IndexSet) {
        var current = users
        current.remove(atOffsets: offsets)
        users = current
        if let data = try? JSONEncoder().encode(current) {
            UserDefaults.standard.set(data, forKey: "mockUsers")
        }
    }

    /// formateur de date
    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
}
