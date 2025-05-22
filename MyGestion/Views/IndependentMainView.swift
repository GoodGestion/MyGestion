import SwiftUI

struct IndependentMainView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @AppStorage("hasProfile") private var hasProfile: Bool = false

    var body: some View {
        Group {
            if hasProfile {
                // Profil déjà complété : on affiche le Dashboard SwiftUI générique
                DashboardView()
            } else {
                // Profil non complété : on redirige vers ProfileView
                ProfileView()
                    .environmentObject(authVM)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Se déconnecter") {
                    authVM.logout()
                }
                .foregroundColor(.red)
            }
        }
    }
}

struct IndependentMainView_Previews: PreviewProvider {
    static var previews: some View {
        IndependentMainView()
            .environmentObject(AuthViewModel())
    }
}
