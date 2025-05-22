import SwiftUI

struct ClientCalendarView: View {
  @EnvironmentObject private var missionVM: MissionViewModel
  @State private var selectedDate = Date()

  var body: some View {
    NavigationView {
      VStack {
        FSCalendarView(
          selectedDate: $selectedDate,
          missions:     missionVM.missions
        )
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)

        NavigationLink("Voir les missions du jour →") {
          MissionListView(
            missions: missionVM.missions,
            date:     selectedDate
          )
          .environmentObject(missionVM)
        }
        .padding()

        Spacer()
      }
      .navigationTitle("Mes missions")
    }
  }
}
