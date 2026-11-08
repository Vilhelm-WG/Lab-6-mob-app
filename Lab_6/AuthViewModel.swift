import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var role: UserRole = .guest
    @Published var email: String = ""
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { await self?.refreshRole(for: user) }
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    var isLoggedIn: Bool { role != .guest }
    var isAdmin: Bool { role == .admin }

    private func refreshRole(for user: User?) async {
        guard let user else {
            role = .guest
            email = ""
            return
        }
        email = user.email ?? ""
        do {
            let doc = try await db.collection("users").document(user.uid).getDocument()
            let value = doc.data()?["role"] as? String ?? "user"
            role = UserRole(rawValue: value) ?? .user
        } catch {
            role = .user
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func register(email: String, password: String) async -> Bool {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // Нові користувачі завжди отримують роль "user".
            // Роль "admin" призначається вручну в консолі Firebase.
            try await db.collection("users").document(result.user.uid)
                .setData(["email": email, "role": "user"])
            await refreshRole(for: result.user)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        role = .guest
    }
}
