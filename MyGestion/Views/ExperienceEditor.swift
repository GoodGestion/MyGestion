import SwiftUI

/// Un petit formulaire pour éditer une Experience
struct ExperienceEditor: View {
    @Binding var experience: Experience
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Expérience")
                    .font(.subheadline).bold()
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
            }

            TextField("Titre", text: $experience.title)
                .textFieldStyle(.roundedBorder)

            TextField("Entreprise", text: $experience.company)
                .textFieldStyle(.roundedBorder)

            DatePicker("Du", selection: $experience.from, displayedComponents: .date)

            DatePicker(
                "Au",
                selection: Binding(
                    get: { experience.to ?? Date() },
                    set: { experience.to = $0 }
                ),
                displayedComponents: .date
            )

            TextField("Description", text: $experience.description)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.vertical, 4)
    }
}
