import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ProfileViewModel()

    @State private var isSelectingSector = false
    @State private var searchSector = ""
    private let allSectors = [
        "Informatique", "Finance", "Marketing", "Ressources Humaines",
        "Vente", "Consulting", "Design", "Logistique",
        "Santé", "Éducation", "Juridique", "Immobilier",
        "Construction", "Tourisme", "Artisanat"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Mon profil")
                    .font(.largeTitle).bold()

                // Secteur
                Button {
                    isSelectingSector = true
                } label: {
                    HStack {
                        Text(vm.sector.isEmpty
                             ? "Sélectionner un secteur d'activité"
                             : vm.sector)
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
                        .searchable(text: $searchSector)
                        .navigationTitle("Secteur d'activité")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Annuler") {
                                    isSelectingSector = false
                                }
                            }
                        }
                    }
                }

                // Expériences
                Text("Expériences").font(.headline)
                ForEach($vm.experiences) { $exp in
                    ExperienceEditor(
                        experience: $exp,
                        onDelete: { vm.experiences.removeAll { $0.id == exp.id } }
                    )
                    Divider()
                }
                Button { addExperience() } label: {
                    Label("Ajouter une expérience", systemImage: "plus.circle")
                }

                // Disponibilités
                Text("Disponibilités").font(.headline)
                ForEach($vm.availabilities) { $avail in
                    AvailabilityEditor(
                        availability: $avail,
                        onDelete: { vm.availabilities.removeAll { $0.id == avail.id } }
                    )
                    Divider()
                }
                Button { addAvailability() } label: {
                    Label("Ajouter une disponibilité", systemImage: "plus.circle")
                }

                // Enregistrer
                if vm.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                }
                Button("Enregistrer le profil") {
                    let token = UserDefaults.standard.string(forKey: "jwt") ?? ""
                    vm.saveProfile(token: token)
                }
                .disabled(vm.isLoading)
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.isLoading ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .alert("Erreur",
               isPresented: Binding(
                   get: { vm.errorMessage != nil },
                   set: { if !$0 { vm.errorMessage = nil } }
               )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .onChange(of: vm.didSave) { saved in
            if saved {
                // Prévenir AuthViewModel que l'indépendant a complété son profil
                authVM.setIndependentProfile(true)
            }
        }
    }

    private var filteredSectors: [String] {
        guard !searchSector.isEmpty else { return allSectors }
        return allSectors.filter {
            $0.localizedCaseInsensitiveContains(searchSector)
        }
    }

    private func addExperience() {
        vm.experiences.append(
            .init(id: UUID(), title: "", company: "", from: Date(), to: nil, description: "")
        )
    }
    private func addAvailability() {
        vm.availabilities.append(
            .init(id: UUID(), dayOfWeek: 1, startHour: "09:00", endHour: "17:00")
        )
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthViewModel())
    }
}
