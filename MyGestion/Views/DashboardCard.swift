import SwiftUI

struct DashboardCard: View {
  let iconName: String
  let title:    String
  let subtitle: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: iconName)
        .font(.largeTitle)
      Text(title)
        .font(.headline)
      Text(subtitle)
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
  }
}
