import SwiftUI

/// Un petit formulaire pour éditer une Availability
struct AvailabilityEditor: View {
    @Binding var availability: Availability
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Disponibilité")
                    .font(.subheadline).bold()
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
            }

            Picker("Jour", selection: $availability.dayOfWeek) {
                Text("Lundi").tag(1)
                Text("Mardi").tag(2)
                Text("Mercredi").tag(3)
                Text("Jeudi").tag(4)
                Text("Vendredi").tag(5)
                Text("Samedi").tag(6)
                Text("Dimanche").tag(7)
            }
            .pickerStyle(.menu)

            TextField("Heure début (HH:mm)", text: $availability.startHour)
                .textFieldStyle(.roundedBorder)

            TextField("Heure fin (HH:mm)", text: $availability.endHour)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.vertical, 4)
    }
}
