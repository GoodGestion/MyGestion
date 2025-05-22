import SwiftUI

@main
struct MyGestionApp: App {
    @StateObject private var authVM    = AuthViewModel()
    @StateObject private var missionVM = MissionViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if !authVM.isLoggedIn {
                    LoginView()
                } else if authVM.role == "admin" {
                    AdminMainView()
                } else if authVM.role == "client" {
                    if authVM.hasClientProfile {
                        ClientMainView()
                    } else {
                        ClientProfileView()
                    }
                } else if authVM.role == "independent" {
                    if authVM.hasIndependentProfile {
                        IndependentMainView()
                    } else {
                        ProfileView()
                    }
                } else {
                    DashboardView()
                }
            }
            .environmentObject(authVM)
            .environmentObject(missionVM)
        }
    }
}
