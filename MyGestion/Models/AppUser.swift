import Foundation

struct AppUser: Identifiable, Codable {
    let id: UUID
    let email: String
    let role: String
    var password: String
    let createdAt: Date
}
