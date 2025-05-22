// Views/CreateOfferView.swift
import SwiftUI

struct CreateOfferView: View {
    @EnvironmentObject private var authVM:    AuthViewModel
    @EnvironmentObject private var missionVM: MissionViewModel
    @StateObject   private var indepVM =       IndependentListViewModel()
    @Environment(\.dismiss) private var dismiss

    let selectedDate:  Date
    let defaultSector: String
    let defaultLocation: String

    // — Formulaire —
    @State private var startTime = Date()
    @State private var endTime   = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var numberOfProviders = 1
    private let maxProviders = 5

    // — Choix du prestataire —
    @State private var selectedProviderEmail: String?

    /// Tous les indépendants qui matchent secteur + localisation
    private var matchingIndependents: [IndependentProfile] {
        indepVM.independents.filter {
            $0.sector   == defaultSector &&
            $0.location == defaultLocation
        }
    }

    // Formatter FR pour la date
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .long
        return f
    }

    var body: some View {
        Form {
            Section(header: Text("Date")) {
                Text(dateFormatter.string(from: selectedDate))
            }

            Section(header: Text("Heure de début")) {
                DatePicker("Début",
                           selection: $startTime,
                           displayedComponents: .hourAndMinute)
            }
            Section(header: Text("Heure de fin")) {
                DatePicker("Fin",
                           selection: $endTime,
                           displayedComponents: .hourAndMinute)
            }

            Section(header: Text("Nombre de prestataires")) {
                Stepper("\(numberOfProviders)",
                        value: $numberOfProviders,
                        in: 1...maxProviders)
            }

            Section(header: Text("Secteur")) {
                Text(defaultSector)
            }
            Section(header: Text("Localisation")) {
                Text(defaultLocation)
            }

            Section(header: Text("Prestataires disponibles")) {
                if matchingIndependents.isEmpty {
                    Text("Aucun prestataire trouvé sur vos critères")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(matchingIndependents) { ip in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(ip.firstName) \(ip.lastName)")
                                Text(ip.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedProviderEmail == ip.email {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedProviderEmail = ip.email
                        }
                    }
                }
            }

            Section {
                Button("Envoyer la demande") {
                    let cal = Calendar.current
                    // compose startDate complet
                    let sd = cal.date(
                        bySettingHour: cal.component(.hour, from: startTime),
                        minute:       cal.component(.minute, from: startTime),
                        second:       0,
                        of: selectedDate
                    )!
                    let ed = cal.date(
                        bySettingHour: cal.component(.hour, from: endTime),
                        minute:       cal.component(.minute, from: endTime),
                        second:       0,
                        of: selectedDate
                    )!

                    missionVM.createMission(
                        title:       "Demande de remplacement",
                        sector:      defaultSector,
                        clientEmail: authVM.email,
                        startDate:   sd,
                        endDate:     ed
                    )
                    // tu peux aussi stocker `selectedProviderEmail` si besoin
                    dismiss()
                }
                .disabled(
                    endTime <= startTime ||
                    selectedProviderEmail == nil
                )
            }
        }
        .navigationTitle("Créer une demande")
        .onAppear {
            indepVM.loadIndependents()
        }
    }
}
