import Foundation

/// État d’une mission
enum MissionStatus: String, Codable {
    case upcoming, ongoing, completed
}

/// Modèle de mission
struct Mission: Identifiable, Codable {
    let id: UUID
    let title: String
    let sector: String
    let clientEmail: String
    let startDate: Date
    let endDate: Date?
    let status: MissionStatus
}
