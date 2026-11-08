import Foundation
import FirebaseFirestore

/// Робота з хмарною базою Cloud Firestore.
/// Колекції: "books" та "categories".
@MainActor
final class BookStore: ObservableObject {
    @Published var books: [Book] = []
    @Published var categories: [Category] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    init() { startListening() }

    deinit { listeners.forEach { $0.remove() } }

    private func startListening() {
        let booksListener = db.collection("books")
            .order(by: "title")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.books = snapshot?.documents.compactMap { try? $0.data(as: Book.self) } ?? []
            }

        let categoriesListener = db.collection("categories")
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.categories = snapshot?.documents.compactMap { try? $0.data(as: Category.self) } ?? []
            }

        listeners = [booksListener, categoriesListener]
    }

    func save(_ book: Book) async {
        do {
            if let id = book.id {
                try db.collection("books").document(id).setData(from: book)
            } else {
                _ = try db.collection("books").addDocument(from: book)
            }
            try await ensureCategory(book.category)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ book: Book) async {
        guard let id = book.id else { return }
        do {
            try await db.collection("books").document(id).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Додає рубрику, якщо її ще немає
    private func ensureCategory(_ name: String) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !categories.contains(where: { $0.name == trimmed }) else { return }
        _ = try db.collection("categories").addDocument(from: Category(name: trimmed))
    }
}
