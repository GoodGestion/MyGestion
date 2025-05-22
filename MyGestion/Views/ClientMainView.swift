import SwiftUI

struct ClientMainView: View {
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var missionVM: MissionViewModel
    @StateObject private var profileVM = ClientProfileViewModel()
    @State private var selectedDate   = Date()

    private var displayName: String {
        if !profileVM.firstName.isEmpty {
            return profileVM.firstName
        }
        return authVM.email
            .components(separatedBy: "@").first?
            .capitalized ?? authVM.email
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Bienvenue, \(displayName) !")
                        .font(.largeTitle).bold()
                        .padding(.top)

                    Text("Ici vous pourrez créer et gérer vos offres de mission.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 16) {
                        NavigationLink {
                            ClientProfileDetailView()
                                .environmentObject(authVM)
                                .environmentObject(missionVM)
                        } label: {
                            DashboardCard(
                                iconName: "person.crop.circle.fill",
                                title:    "Mon profil",
                                subtitle: "Voir mes informations"
                            )
                        }

                        NavigationLink {
                            CreateOfferView(
                                selectedDate:    selectedDate,
                                defaultSector:   profileVM.sector,
                                defaultLocation: profileVM.location
                            )
                            .environmentObject(authVM)
                            .environmentObject(missionVM)
                        } label: {
                            DashboardCard(
                                iconName: "plus.circle.fill",
                                title:    "Créer une Demande",
                                subtitle: "Publier une mission"
                            )
                        }
                    }
                    .padding(.horizontal)

                    // ── Très important : on force à 100% de la largeur
                    FSCalendarView(
                        selectedDate: $selectedDate,
                        missions:     missionVM.missions
                    )
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)   // ← c’est ce qui évite le 0 width
                    .padding(.horizontal)

                    Spacer()

                    Button("Se déconnecter") {
                        authVM.logout()
                    }
                    .foregroundColor(.red)
                    .padding(.bottom, 30)
                }
                .padding(.vertical)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                profileVM.loadMockProfile(for: authVM.email)
                // petit “twist” pour déclencher updateUIView()
                DispatchQueue.main.async {
                    self.selectedDate = self.selectedDate
                }
            }
        }
    }
}

// Formatter FR
private let dayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale    = Locale(identifier: "fr_FR")
    f.dateStyle = .medium
    return f
}()

struct ClientMainView_Previews: PreviewProvider {
    static var previews: some View {
        ClientMainView()
            .environmentObject(AuthViewModel())
            .environmentObject(MissionViewModel())
    }
}
