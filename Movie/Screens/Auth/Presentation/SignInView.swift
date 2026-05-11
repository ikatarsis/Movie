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

    private let bioCoordinator: BioAuthCoordinator
    @State private var enableBioQuickSignIn = false
    @State private var bioSetupMessage: String?

    init(
        isSignIn: Binding<Bool>,
        signInUseCase: SignInUseCase,
        bioCoordinator: BioAuthCoordinator
    ) {
        _isSignIn = isSignIn
        _viewModel = StateObject(wrappedValue: SignInViewModel(signIn: signInUseCase))
        self.bioCoordinator = bioCoordinator
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

            Toggle("Сохранить быстрый вход по Face ID", isOn: $enableBioQuickSignIn)
                .font(.subheadline)

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

            if BioQuickSignInStorage.isEnabled {
                Button {
                    Task {
                        await signInWithBio()
                    }
                } label: {
                    Label("Войти по Face ID", systemImage: "faceid")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
            }

            if let message = viewModel.errorMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let bioMessage = bioSetupMessage {
                Text(bioMessage)
                    .foregroundColor(.orange)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Text("Нет аккаунта?")
                Button("Зарегестрироваться") { isSignIn = true }
                    .foregroundColor(.blue)
            }
        }
        .onChange(of: viewModel.didSignInSucceed) { _, ok in
            guard ok, enableBioQuickSignIn else { return }
            Task {
                do {
                    try await bioCoordinator.enableQuickSignIn()
                    bioSetupMessage = nil
                } catch let e as AuthError {
                    bioSetupMessage = e.userMessage
                } catch {
                    bioSetupMessage = error.localizedDescription
                }
            }
        }
        .padding()
    }

    private func signInWithBio() async {
        bioSetupMessage = nil
        do {
            try await bioCoordinator.signInWithStoredBio()
        } catch let e as AuthError {
            bioSetupMessage = e.userMessage
        } catch {
            bioSetupMessage = error.localizedDescription
        }
    }
}

#Preview {
    struct MockAuthRepository: AuthRepository {
        func signIn(email: String, password: String) async throws {}
        func signUp(email: String, password: String) async throws {}
        func signOut() throws {}
        func signIn(withCustomToken token: String) async throws {}
    }

    let repo = MockAuthRepository()
    let useCase = SignInUseCase(repository: repo)
    let coordinator = BioAuthCoordinator(authRepository: repo)
    return SignInView(isSignIn: .constant(false), signInUseCase: useCase, bioCoordinator: coordinator)
}
