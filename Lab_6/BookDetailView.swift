import SwiftUI

/// Окремий екран з коротким змістом книги.
/// Гість бачить обкладинку й дані, але зміст доступний лише після входу.
struct BookDetailView: View {
    @EnvironmentObject var auth: AuthViewModel
    let book: Book
    @State private var showLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: book.coverURL)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "book.closed").font(.system(size: 60)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: 320)

                Text(book.title).font(.title.bold())
                Text(book.authorsText).font(.title3).foregroundStyle(.secondary)
                Label("\(book.pages) сторінок", systemImage: "doc.text")
                Label(book.category, systemImage: "tag")

                Divider()
                Text("Короткий зміст").font(.headline)

                if auth.isLoggedIn {
                    Text(book.summary)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "lock.fill").font(.title)
                        Text("Короткий зміст доступний лише авторизованим користувачам")
                            .multilineTextAlignment(.center)
                        Button("Увійти") { showLogin = true }
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Про книгу")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLogin) { LoginView() }
    }
}
