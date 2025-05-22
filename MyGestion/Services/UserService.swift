// Services/UserService.swift
import Foundation
import Combine

final class UserService {
    static let shared = UserService()
    private let baseURL = URL(string: "https://api.tondomaine.com")!

    /// Session avec timeout plus long
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 30  // 30s
        config.timeoutIntervalForResource = 60  // 60s
        return URLSession(configuration: config)
    }()

    private init() {}

    // MARK: – Réel
    func saveProfile(_ profile: IndependentProfile, token: String) -> AnyPublisher<Void, AuthError> {
        var req = URLRequest(url: baseURL.appendingPathComponent("/profile"))
        req.httpMethod = "POST"
        req.timeoutInterval = 30
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            req.httpBody = try JSONEncoder().encode(profile)
        } catch {
            return Fail(error: AuthError.serverError("Impossible d’encoder le profil"))
                .eraseToAnyPublisher()
        }

        return session
            .dataTaskPublisher(for: req)
            .mapError { _ in AuthError.unknown }
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse else {
                    throw AuthError.unknown
                }
                switch http.statusCode {
                case 200, 201:
                    return ()
                case 401:
                    throw AuthError.invalidCredentials
                default:
                    let msg = String(data: data, encoding: .utf8) ?? "Code \(http.statusCode)"
                    throw AuthError.serverError(msg)
                }
            }
            .mapError { $0 as? AuthError ?? .unknown }
            .eraseToAnyPublisher()
    }

    // MARK: – Mock pour tests
    #if DEBUG
    func saveProfileMock(_ profile: IndependentProfile, token: String) -> AnyPublisher<Void, AuthError> {
        Just(())
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .setFailureType(to: AuthError.self)
            .eraseToAnyPublisher()
    }
    #endif
}
