//
//  LogIn.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 04.05.2026.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var authError: String?
    @Binding var isSignIn: Bool
    
    private let emailRegex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$/
    
    func validateEmail() {
        if email.isEmpty {
            authError = "Поле не может быть пустым"
            return
        }
        if email.wholeMatch(of: emailRegex) != nil {
            authError = nil
        } else {
            authError = "Неверный формат email"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Вход")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.default)
                .autocapitalization(.none)
            
            Button {
                authError = nil
                Task {
                        do {
                            try await Auth.auth().signIn(withEmail: email, password: password)
                        } catch {
                            authError = error.localizedDescription
                        }
                    }
            } label: {
                Text("Войти")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            HStack {
                Text("Нет аккаунта?")
                Button("Зарегестрироваться") {
                    isSignIn = true
                }
                .foregroundColor(.blue)
            }
            
        }
        .padding()
    }
}

#Preview {
    SignInView(isSignIn: .constant(false))
}
