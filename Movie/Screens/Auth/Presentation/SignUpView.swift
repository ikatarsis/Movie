//
//  SignIn.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 05.05.2026.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var authError: String?
    @State private var isLoading: Bool = false
    @Binding var isSignIn: Bool
    
    var body: some View {
    VStack(spacing: 20) {
        Text("Регистрация")
            .font(.largeTitle)
            .bold()
        
        TextField("Email", text: $email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.emailAddress)
            // запрещает автоматически делать первую букву строки или слов заглавной
            .textInputAutocapitalization(.never)
            // отключает автокоррекцию (T9)
            .autocorrectionDisabled()
        
        SecureField("Пароль", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.default)
        
        SecureField("Повторите пароль", text: $confirmPassword)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.default)
        
        Button {
            Task{
                await register()
            }
        } label: {
            Text(isLoading ? "Загрузка..." : "Зарегистрироваться")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(isLoading)

        if let authError {
            Text(authError)
                .foregroundColor(.red)
                .font(.footnote)
        }
        
        HStack {
            Text("Есть аккаунт?")
            Button("Войти") {
                isSignIn = false
            }
            .foregroundColor(.blue)
        }
        
    }
    .padding()
}

    private func register() async {
        authError = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            authError = "Введите email"
            return
        }

        guard !password.isEmpty, !confirmPassword.isEmpty else {
            authError = "Введите пароль и подтверждение"
            return
        }

        guard password == confirmPassword else {
            authError = "Пароли не совпадают"
            return
        }

        guard password.count >= 6 else {
            authError = "Пароль должен быть минимум 6 символов"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await Auth.auth().createUser(withEmail: trimmedEmail, password: password)
            isSignIn = false
        } catch {
            authError = error.localizedDescription
        }
    }
}

#Preview {
    SignUpView(isSignIn: .constant(true))
}
