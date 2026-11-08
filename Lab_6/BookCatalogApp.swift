import SwiftUI
import FirebaseCore

@main
struct BookCatalogApp: App {
    @StateObject private var auth: AuthViewModel

    init() {
        // Потрібен файл GoogleService-Info.plist у проєкті
        FirebaseApp.configure()
        _auth = StateObject(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            CatalogView()
                .environmentObject(auth)
        }
    }
}
