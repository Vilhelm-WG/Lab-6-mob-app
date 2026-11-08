import SwiftUI

/// Додавання / редагування книги (лише для адміністратора)
struct BookEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: BookStore
    let book: Book?

    @State private var title = ""
    @State private var authors = ""
    @State private var pages = ""
    @State private var category = ""
    @State private var coverURL = ""
    @State private var summary = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Основне") {
                    TextField("Назва", text: $title)
                    TextField("Автори (через кому)", text: $authors)
                    TextField("Кількість сторінок", text: $pages).keyboardType(.numberPad)
                    TextField("URL обкладинки", text: $coverURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
                Section("Рубрика") {
                    if !store.categories.isEmpty {
                        Picker("Існуюча", selection: $category) {
                            Text("—").tag("")
                            ForEach(store.categories) { Text($0.name).tag($0.name) }
                        }
                    }
                    TextField("Або нова рубрика", text: $category)
                }
                Section("Короткий зміст") {
                    TextEditor(text: $summary).frame(minHeight: 140)
                }
            }
            .navigationTitle(book == nil ? "Нова книга" : "Редагування")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Скасувати") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") { Task { await save() } }
                        .disabled(title.isEmpty || category.isEmpty || Int(pages) == nil)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let book else { return }
        title = book.title
        authors = book.authorsText
        pages = String(book.pages)
        category = book.category
        coverURL = book.coverURL
        summary = book.summary
    }

    private func save() async {
        var item = book ?? Book(title: "", authors: [], pages: 0, category: "", coverURL: "", summary: "")
        item.title = title
        item.authors = authors.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        item.pages = Int(pages) ?? 0
        item.category = category.trimmingCharacters(in: .whitespaces)
        item.coverURL = coverURL
        item.summary = summary
        await store.save(item)
        dismiss()
    }
}
