import SwiftUI

struct CatalogView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var store = BookStore()

    private let allCategories = "Усі рубрики"
    @State private var selectedCategory = "Усі рубрики"
    @State private var showLogin = false
    @State private var editorBook: Book?
    @State private var showNewBook = false

    private var filteredBooks: [Book] {
        selectedCategory == allCategories
            ? store.books
            : store.books.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryPicker
                List {
                    ForEach(filteredBooks) { book in
                        NavigationLink {
                            BookDetailView(book: book)
                        } label: {
                            BookRow(book: book)
                        }
                        .swipeActions {
                            if auth.isAdmin {
                                Button(role: .destructive) {
                                    Task { await store.delete(book) }
                                } label: { Label("Видалити", systemImage: "trash") }
                                Button { editorBook = book } label: {
                                    Label("Змінити", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if filteredBooks.isEmpty {
                        ContentUnavailableView("Книг немає", systemImage: "books.vertical",
                                               description: Text("У цій рубриці поки порожньо"))
                    }
                }
            }
            .navigationTitle("Каталог книг")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if auth.isLoggedIn {
                        Menu {
                            Text(auth.email)
                            Text(auth.isAdmin ? "Роль: адміністратор" : "Роль: користувач")
                            Button("Вийти", role: .destructive) { auth.signOut() }
                        } label: { Image(systemName: "person.crop.circle.fill") }
                    } else {
                        Button("Увійти") { showLogin = true }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if auth.isAdmin {
                        Button { showNewBook = true } label: { Image(systemName: "plus") }
                    }
                }
            }
            .sheet(isPresented: $showLogin) { LoginView() }
            .sheet(isPresented: $showNewBook) {
                BookEditView(store: store, book: nil)
            }
            .sheet(item: $editorBook) { book in
                BookEditView(store: store, book: book)
            }
            .alert("Помилка", isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.errorMessage = nil } })
            ) {
                Button("OK", role: .cancel) {}
            } message: { Text(store.errorMessage ?? "") }
        }
    }

    private var categoryPicker: some View {
        HStack {
            Text("Рубрика:").foregroundStyle(.secondary)
            Picker("Рубрика", selection: $selectedCategory) {
                Text(allCategories).tag(allCategories)
                ForEach(store.categories) { Text($0.name).tag($0.name) }
            }
            .pickerStyle(.menu)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct BookRow: View {
    let book: Book

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: book.coverURL)) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure: Image(systemName: "book.closed").font(.title).foregroundStyle(.secondary)
                default: ProgressView()
                }
            }
            .frame(width: 60, height: 90)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title).font(.headline)
                Text(book.authorsText).font(.subheadline).foregroundStyle(.secondary)
                Text("\(book.pages) стор.").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
