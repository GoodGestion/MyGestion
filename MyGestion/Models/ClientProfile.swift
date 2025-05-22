import Foundation

struct ClientProfile: Codable, Identifiable {
    let id = UUID()

    var email: String
    var role: String

    var sector: String
    var location: String

    // Nouveaux champs
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var siret: String
}
