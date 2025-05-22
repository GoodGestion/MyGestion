import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.presentationMode) private var presentation
    @StateObject private var vm = SignUpViewModel()
    @State private var showReset = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Inscription")
                    .font(.largeTitle).bold()

                // Choix du rôle
                Picker("Vous êtes", selection: $vm.role) {
                    Text("Indépendant·e").tag("independent")
                    Text("Chef·fe d’entreprise").tag("client")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Email
                TextField("Email", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                // Mot de passe
                SecureField("Mot de passe", text: $vm.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                // Confirmation mot de passe
                SecureField("Confirme mot de passe", text: $vm.confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                // Spinner lors de l’enregistrement
                if vm.isLoading {
                    ProgressView().padding()
                }

                // Bouton S'inscrire
                Button("S'inscrire") {
                    vm.register()
                }
                .disabled(vm.isLoading)
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.isLoading ? Color.gray : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Annuler") {
                presentation.wrappedValue.dismiss()
            })
            // Alerte d’erreur générique
            .alert("Erreur", isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
            // Alerte e-mail déjà utilisé
            .alert("Email déjà utilisé",
                   isPresented: $vm.showEmailExistsAlert) {
                Button("Mot de passe oublié ?") {
                    showReset = true
                }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Cet email est déjà enregistré.")
            }
            // Feuille de réinitialisation
            .sheet(isPresented: $showReset) {
                PasswordResetView(email: vm.email)
                    .environmentObject(authVM)
            }
            // Après inscription réussie
            .onChange(of: vm.didRegister) { _, reg in
                if reg {
                    // Forcer hasProfile à false pour le nouvel utilisateur
                    UserDefaults.standard.set(false, forKey: "hasProfile")
                    // Puis login automatique
                    authVM.login(email: vm.email, password: vm.password)
                    presentation.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
