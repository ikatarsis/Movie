//
//  SignIn.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 05.05.2026.
//

import SwiftUI

struct SignUpView: View {
    @Binding var isSignIn: Bool
    @StateObject private var viewModel: SignUpViewModel
    
    init(isSignIn: Binding<Bool>, signUpUseCase: SignUpUseCase){
        _isSignIn = isSignIn
        _viewModel = StateObject(wrappedValue: SignUpViewModel(signUp: signUpUseCase))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
            // запрещает автоматически делать первую букву строки или слов заглавной
                .textInputAutocapitalization(.never)
            // отключает автокоррекцию (T9)
                .autocorrectionDisabled()

            if let text = viewModel.emailFieldError {
                Text(text)
                    .foregroundColor(.red)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.default)

            if let text = viewModel.passwordFieldError {
                Text(text)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            SecureField("Повторите пароль", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.default)

            if let text = viewModel.confirmPasswordFieldError {
                Text(text)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button {
                Task{  await viewModel.submit() }
            } label: {
                Text(viewModel.isLoading ? "Загрузка..." : "Зарегистрироваться")
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
                Text("Есть аккаунт?")
                Button("Войти") { isSignIn = false }
                    .foregroundColor(.blue)
            }
            
        }
        .padding()
        .onChange(of: viewModel.didComplete) { _, done in
            if done { isSignIn = false }
        }
    }
    
    #Preview {
        struct MockAuthRepository: AuthRepository {
            func signIn(email: String, password: String) async throws {}
            func signUp(email: String, password: String) async throws {}
            func signOut() throws {}
        }
        
        let useCase = SignUpUseCase(repository: MockAuthRepository())
        return SignUpView(isSignIn: .constant(true), signUpUseCase: useCase)}
}
