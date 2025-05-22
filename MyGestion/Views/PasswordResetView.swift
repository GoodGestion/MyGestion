import SwiftUI

struct PasswordResetView: View {
    @Environment(\.presentationMode) private var presentation
    @StateObject private var vm: PasswordResetViewModel

    init(email: String) { _vm = StateObject(wrappedValue: PasswordResetViewModel(email: email)) }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Nouveau mot de passe")
                    .font(.title2).bold()

                SecureField("Nouveau mot de passe", text: $vm.newPassword)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)

                SecureField("Confirme mot de passe", text: $vm.confirmPassword)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)

                if vm.isLoading {
                    ProgressView().padding()
                }

                Button("Réinitialiser") {
                    vm.resetPassword()
                }
                .disabled(vm.isLoading)
                .frame(maxWidth: .infinity).padding()
                .background(vm.isLoading ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Annuler") {
                presentation.wrappedValue.dismiss()
            })
            .alert("Erreur", isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
            .onChange(of: vm.didReset) { _, ok in
                if ok { presentation.wrappedValue.dismiss() }
            }
        }
    }
}
