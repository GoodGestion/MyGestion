import SwiftUI

struct MissionListView: View {
    let missions: [Mission]
    let date: Date

    private var todaysMissions: [Mission] {
        missions.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: date)
        }
    }

    var body: some View {
        List {
            if todaysMissions.isEmpty {
                Text("Aucune mission ce jour-là")
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                ForEach(todaysMissions) { m in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(m.title).font(.headline)
                        Text(m.sector)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(m.status.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(Self.titleFormatter.string(from: date))
    }

    private static let titleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()
}
