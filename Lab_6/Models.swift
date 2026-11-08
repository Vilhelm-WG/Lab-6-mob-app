import Foundation
import FirebaseFirestore

/// Ролі користувача:
/// guest  – не авторизований (бачить каталог, але не короткий зміст)
/// user   – авторизований (бачить і короткий зміст)
/// admin  – адміністратор (+ додавання, редагування, видалення книг)
enum UserRole: String {
    case guest, user, admin
}

struct Book: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var authors: [String]
    var pages: Int
    var category: String
    var coverURL: String
    var summary: String

    var authorsText: String { authors.joined(separator: ", ") }
}

struct Category: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
}
