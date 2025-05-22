import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel

    private var displayName: String {
        authVM.email
            .components(separatedBy: "@").first?
            .capitalized ?? authVM.email
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Bienvenue, \(displayName) !")
                    .font(.title2)
                    .padding()

                Spacer()
                NavigationLink("Mon profil") {
                    // Si indépendant, affiche ProfileDetailView
                    // sinon ClientProfileView
                    if authVM.role == "independent" {
                        ProfileView()
                            .environmentObject(authVM)
                    } else {
                        ClientProfileView()
                            .environmentObject(authVM)
                    }
                }
                .padding()

                Spacer()

                Button("Se déconnecter") {
                    authVM.logout()
                }
                .foregroundColor(.red)

                Spacer()
            }
            .navigationTitle("Tableau de bord")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}
