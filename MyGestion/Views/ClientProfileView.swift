import SwiftUI

// ──────────────────────────────────────────────
// Composant réutilisable pour afficher une ligne
// ──────────────────────────────────────────────
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// ──────────────────────────────────────────────
// Composant réutilisable pour un TextField "flottant"
// ──────────────────────────────────────────────
struct FloatingTextField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("", text: $text)
                .keyboardType(keyboard)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

// ──────────────────────────────────────────────
// Vue d’édition du profil client
// ──────────────────────────────────────────────
struct ClientProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ClientProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    // MARK: – pour le pickeur secteur
    @State private var isSelectingSector   = false
    @State private var sectorSearch        = ""
    private let allSectors = [
        "Informatique", "Finance", "Marketing", "Ressources Humaines",
        "Vente", "Consulting", "Design", "Logistique",
        "Santé", "Éducation", "Juridique", "Immobilier",
        "Construction", "Tourisme", "Artisanat"
    ]

    // MARK: – pour le pickeur localisation
    @State private var isSelectingLocation = false
    @State private var locationSearch     = ""
    private let allLocations = [
        "Paris, 75001", "Lyon, 69001", "Marseille, 13001",
        "Toulouse, 31000", "Bordeaux, 33000", "Lille, 59000",
        "Nantes, 44000", "Strasbourg, 67000", "Rennes, 35000"
    ]

    private var displayName: String {
        authVM.email
            .components(separatedBy: "@").first?
            .capitalized ?? authVM.email
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Mon profil")
                    .font(.largeTitle).bold()
                    .padding(.top)

                InfoRow(label: "Nom d’utilisateur", value: displayName)
                InfoRow(label: "Email",            value: authVM.email)
                InfoRow(label: "Rôle",             value: "Chef·fe d’entreprise")

                FloatingTextField(label: "Prénom",    text: $vm.firstName)
                FloatingTextField(label: "Nom",       text: $vm.lastName)
                FloatingTextField(label: "Téléphone", text: $vm.phoneNumber, keyboard: .phonePad)
                FloatingTextField(label: "SIRET (14)", text: $vm.siret,       keyboard: .numberPad)

                // — Picker Secteur —
                VStack(alignment: .leading, spacing: 4) {
                    Text("Secteur d’activité")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button {
                        isSelectingSector = true
                    } label: {
                        HStack {
                            Text(vm.sector.isEmpty ? "Sélectionner…" : vm.sector)
                                .foregroundColor(vm.sector.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $isSelectingSector) {
                        NavigationView {
                            List(filteredSectors, id: \.self) { s in
                                Button(s) {
                                    vm.sector = s
                                    isSelectingSector = false
                                }
                            }
                            .searchable(text: $sectorSearch)
                            .navigationTitle("Secteur d’activité")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Annuler") {
                                        isSelectingSector = false
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // — Picker Localisation —
                VStack(alignment: .leading, spacing: 4) {
                    Text("Localisation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button {
                        isSelectingLocation = true
                    } label: {
                        HStack {
                            Text(vm.location.isEmpty ? "Sélectionner…" : vm.location)
                                .foregroundColor(vm.location.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $isSelectingLocation) {
                        NavigationView {
                            List(filteredLocations, id: \.self) { loc in
                                Button(loc) {
                                    vm.location = loc
                                    isSelectingLocation = false
                                }
                            }
                            .searchable(text: $locationSearch)
                            .navigationTitle("Localisation")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Annuler") {
                                        isSelectingLocation = false
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // — Enregistrer —
                Button {
                    vm.saveProfile(
                        token: UserDefaults.standard.string(forKey: "jwt") ?? "",
                        email: authVM.email,
                        role:  authVM.role ?? "client"
                    )
                } label: {
                    Text("Enregistrer le profil")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(vm.isLoading ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(
                    vm.isLoading ||
                    vm.firstName.isEmpty ||
                    vm.lastName.isEmpty ||
                    vm.phoneNumber.isEmpty ||
                    vm.siret.count != 14 ||
                    vm.sector.isEmpty ||
                    vm.location.isEmpty
                )

                Spacer(minLength: 20)
            }
            .padding(.bottom)
        }
        .navigationTitle("Mon profil")
        .onAppear {
            vm.loadMockProfile(for: authVM.email)
        }
        .alert("Erreur",
               isPresented: Binding(
                   get: { vm.errorMessage != nil },
                   set: { if !$0 { vm.errorMessage = nil } }
               )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .onChange(of: vm.didSave) { saved in
            guard saved else { return }
            authVM.setClientProfile(true)
            dismiss()
        }
    }

    // MARK: – Helpers
    private var filteredSectors: [String] {
        guard !sectorSearch.isEmpty else { return allSectors }
        return allSectors.filter {
            $0.localizedCaseInsensitiveContains(sectorSearch)
        }
    }

    private var filteredLocations: [String] {
        guard !locationSearch.isEmpty else { return allLocations }
        return allLocations.filter {
            $0.localizedCaseInsensitiveContains(locationSearch)
        }
    }
}
