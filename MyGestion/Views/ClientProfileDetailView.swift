// Views/ClientProfileDetailView.swift
import SwiftUI

struct ClientProfileDetailView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ClientProfileViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                InfoRow(label: "Nom d’utilisateur",
                        value: authVM.email
                            .components(separatedBy: "@")
                            .first?
                            .capitalized ?? "")

                InfoRow(label: "Email",
                        value: authVM.email)

                InfoRow(label: "Rôle",
                        value: "Chef·fe d’entreprise")

                InfoRow(label: "Prénom",
                        value: vm.firstName)

                InfoRow(label: "Nom",
                        value: vm.lastName)

                InfoRow(label: "Téléphone",
                        value: vm.phoneNumber)

                InfoRow(label: "SIRET",
                        value: vm.siret)

                InfoRow(label: "Secteur d’activité",
                        value: vm.sector)

                InfoRow(label: "Localisation",
                        value: vm.location)
            }
            .padding()
        }
        .navigationTitle("Mon profil")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Modifier") {
                    ClientProfileView()
                        .environmentObject(authVM)
                }
            }
        }
        .onAppear {
            // Charge le mock pour pré-remplir les valeurs
            vm.loadMockProfile(for: authVM.email)
        }
    }
}

struct ClientProfileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClientProfileDetailView()
                .environmentObject(AuthViewModel())
        }
    }
}
