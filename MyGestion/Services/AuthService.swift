import Foundation
import Combine

// MARK: – Models

struct LoginResponse: Decodable {
    let token: String
    let role: String
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case serverError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email ou mot de passe invalide."
        case .emailAlreadyInUse:
            return "Cet email est déjà utilisé."
        case .serverError(let msg):
            return msg
        case .unknown:
            return "Une erreur inattendue est survenue."
        }
    }
}

final class AuthService {
    static let shared = AuthService()
    private let baseURL = URL(string: "https://api.tondomaine.com")!  // ← adapte ton URL

    private init() {}

    /// Login : mock en DEBUG, sinon appel réseau
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, AuthError> {
        #if DEBUG
        // 1) Admin direct
        if email.lowercased() == "admin@domain.com" {
            return Just(LoginResponse(token: "admin-token-000", role: "admin"))
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        // 2) Utilisateur inscrit en mockUsers
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "mockUsers"),
           let users = try? JSONDecoder().decode([AppUser].self, from: data),
           let user = users.first(where: {
             $0.email.lowercased() == email.lowercased() &&
             $0.password == password
           }) {
            return Just(LoginResponse(token: "demo-token-123", role: user.role))
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        // 3) Mauvaises infos
        return Fail(error: AuthError.invalidCredentials)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        #else
        // Implémentation réelle
        var req = URLRequest(url: baseURL.appendingPathComponent("/login"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(["email": email, "password": password])

        return URLSession.shared.dataTaskPublisher(for: req)
            .mapError { _ in AuthError.unknown }
            .flatMap { data, response -> AnyPublisher<LoginResponse, AuthError> in
                guard let http = response as? HTTPURLResponse else {
                    return Fail(error: .unknown).eraseToAnyPublisher()
                }
                switch http.statusCode {
                case 200:
                    return Just(data)
                        .decode(type: LoginResponse.self, decoder: JSONDecoder())
                        .mapError { _ in AuthError.unknown }
                        .eraseToAnyPublisher()
                case 401:
                    return Fail(error: .invalidCredentials).eraseToAnyPublisher()
                default:
                    let msg = String(data: data, encoding: .utf8) ?? "Code \(http.statusCode)"
                    return Fail(error: .serverError(msg)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
        #endif
    }

    /// Register : mock en DEBUG, sinon appel réseau
    func register(email: String, password: String, role: String) -> AnyPublisher<Void, AuthError> {
        #if DEBUG
        return Future<Void, AuthError> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let defaults = UserDefaults.standard
                var users: [AppUser] = []
                if let data = defaults.data(forKey: "mockUsers"),
                   let decoded = try? JSONDecoder().decode([AppUser].self, from: data) {
                    users = decoded
                }
                // déjà existant ?
                if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
                    promise(.failure(.emailAlreadyInUse))
                    return
                }
                // créer
                let newUser = AppUser(
                    id: UUID(),
                    email: email,
                    role: role,
                    password: password,
                    createdAt: Date()
                )
                users.append(newUser)
                if let encoded = try? JSONEncoder().encode(users) {
                    defaults.set(encoded, forKey: "mockUsers")
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
        #else
        let url = baseURL.appendingPathComponent("/register")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(["email": email, "password": password, "role": role])

        return URLSession.shared.dataTaskPublisher(for: req)
            .mapError { _ in AuthError.unknown }
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse else {
                    throw AuthError.unknown
                }
                switch http.statusCode {
                case 201:
                    return ()
                case 409:
                    throw AuthError.emailAlreadyInUse
                default:
                    let msg = String(data: data, encoding: .utf8) ?? "Code \(http.statusCode)"
                    throw AuthError.serverError(msg)
                }
            }
            .mapError { err in (err as? AuthError) ?? .unknown }
            .eraseToAnyPublisher()
        #endif
    }

    /// Validation de token mock en DEBUG, sinon réseau
    func validateToken() -> AnyPublisher<LoginResponse, AuthError> {
        #if DEBUG
        // 1) Admin-token
        if let token = UserDefaults.standard.string(forKey: "jwt"),
           token == "admin-token-000" {
            return Just(LoginResponse(token: token, role: "admin"))
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        // 2) Demo-token (on relit le rôle dans mockUsers)
        if let token = UserDefaults.standard.string(forKey: "jwt"),
           token == "demo-token-123",
           let data = UserDefaults.standard.data(forKey: "mockUsers"),
           let users = try? JSONDecoder().decode([AppUser].self, from: data),
           let first = users.first {
            return Just(LoginResponse(token: token, role: first.role))
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: AuthError.unknown).eraseToAnyPublisher()
        #else
        guard let token = UserDefaults.standard.string(forKey: "jwt") else {
            return Fail(error: AuthError.unknown).eraseToAnyPublisher()
        }
        var req = URLRequest(url: baseURL.appendingPathComponent("/me"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: req)
            .mapError { _ in AuthError.unknown }
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw AuthError.unknown
                }
                return try JSONDecoder().decode(LoginResponse.self, from: data)
            }
            .mapError { $0 as? AuthError ?? .unknown }
            .eraseToAnyPublisher()
        #endif
    }
}
