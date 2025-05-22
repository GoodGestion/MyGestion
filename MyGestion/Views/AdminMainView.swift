import SwiftUI

struct AdminMainView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = AdminViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.users) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.email).bold()
                        Text("Rôle : \(user.role.capitalized)")
                            .font(.subheadline)
                        Text("Inscrit le : \(vm.dateFormatter.string(from: user.createdAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Gestion des inscrits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("🔄 Refresh") { vm.fetchAllUsers() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Se déconnecter") { authVM.logout() }
                        .foregroundColor(.red)
                }
            }
            .onAppear { vm.fetchAllUsers() }
        }
        .alert("Erreur", isPresented: $vm.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage)
        }
    }
}

struct AdminMainView_Previews: PreviewProvider {
    static var previews: some View {
        AdminMainView()
            .environmentObject(AuthViewModel())
    }
}
