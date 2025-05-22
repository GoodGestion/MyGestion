import Foundation
import Combine

final class MissionViewModel: ObservableObject {
    @Published var missions: [Mission] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadMockMissions()
    }

    func loadMockMissions() {
        let now       = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow  = Calendar.current.date(byAdding: .day, value: +1, to: now)!

        let sample = [
            Mission(
                id: UUID(),
                title: "Visite client",
                sector: "Consulting",
                clientEmail: "contact@exemple.com",
                startDate: yesterday,
                endDate:   nil,
                status:    .ongoing
            ),
            Mission(
                id: UUID(),
                title: "Audit marketing",
                sector: "Marketing",
                clientEmail: "contact@exemple.com",
                startDate: tomorrow,
                endDate:   nil,
                status:    .upcoming
            )
        ]

        Just(sample)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] in self?.missions = $0 }
            .store(in: &cancellables)
    }

    /// Crée une nouvelle mission et l’ajoute à la liste
    func createMission(
        title: String,
        sector: String,
        clientEmail: String,
        startDate: Date,
        endDate: Date
    ) {
        let new = Mission(
            id: UUID(),
            title: title,
            sector: sector,
            clientEmail: clientEmail,
            startDate: startDate,
            endDate: endDate,
            status: .upcoming
        )
        missions.append(new)
    }
}
