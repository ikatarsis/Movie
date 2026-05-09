//
//  LogIn.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 04.05.2026.
//

import SwiftUI

struct SignInView: View {
    @Binding var isSignIn: Bool
    @StateObject private var viewModel: SignInViewModel
    
    init(isSignIn: Binding<Bool>, signInUseCase: SignInUseCase) {
        _isSignIn = isSignIn
        _viewModel = StateObject(wrappedValue: SignInViewModel(signIn: signInUseCase))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Вход")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
            Button {
                Task { await viewModel.submit() }
            } label: {
                Text(viewModel.isLoading ? "Загрузка..." : "Войти")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.canSubmit)
            
            if let message = viewModel.errorMessage {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
            
            HStack {
                Text("Нет аккаунта?")
                Button("Зарегестрироваться") { isSignIn = true }
                .foregroundColor(.blue)
            }
            
        }
        .padding()
    }
}

#Preview {
    struct MockAuthRepository: AuthRepository {
            func signIn(email: String, password: String) async throws {}
            func signUp(email: String, password: String) async throws {}
            func signOut() throws {}
        }
    
    let useCase = SignInUseCase(repository: MockAuthRepository())
    return SignInView(isSignIn: .constant(false), signInUseCase: useCase)}
