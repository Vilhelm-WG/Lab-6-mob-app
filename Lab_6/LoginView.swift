import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Пароль (мін. 6 символів)", text: $password)
                }
                if let error = auth.errorMessage {
                    Text(error).foregroundStyle(.red).font(.footnote)
                }
                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        if isLoading { ProgressView() }
                        else { Text(isRegistering ? "Зареєструватися" : "Увійти") }
                    }
                    .disabled(email.isEmpty || password.count < 6 || isLoading)

                    Button(isRegistering ? "Вже є акаунт? Увійти" : "Немає акаунта? Реєстрація") {
                        isRegistering.toggle()
                        auth.errorMessage = nil
                    }
                    .font(.footnote)
                }
            }
            .navigationTitle(isRegistering ? "Реєстрація" : "Вхід")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрити") { dismiss() }
                }
            }
        }
    }

    private func submit() async {
        isLoading = true
        let ok = isRegistering
            ? await auth.register(email: email, password: password)
            : await auth.signIn(email: email, password: password)
        isLoading = false
        if ok { dismiss() }
    }
}
