import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Connexion")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .accessibilityIdentifier("login_email")
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            SecureField("Mot de passe", text: $password)
                .accessibilityIdentifier("login_password")
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            ZStack {
                Button(action: {
                    // Ne lance pas le login si les champs sont vides
                    guard !email.isEmpty, !password.isEmpty else { return }
                    authVM.login(email: email, password: password)
                }) {
                    Text("Se connecter")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((email.isEmpty || password.isEmpty || authVM.isLoading) ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)
                .accessibilityIdentifier("login_button")

                if authVM.isLoading {
                    ProgressView()
                        .accessibilityIdentifier("login_spinner")
                }
            }

            Button("Pas de compte ? Inscrivez-vous") {
                showSignup = true
            }
            .accessibilityIdentifier("login_showSignup")
            .padding(.top, 10)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showSignup) {
            SignUpView()
                .environmentObject(authVM)
        }
        .alert("Erreur", isPresented: Binding(
            get: { authVM.errorMessage != nil },
            set: { _ in authVM.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authVM.errorMessage ?? "")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
