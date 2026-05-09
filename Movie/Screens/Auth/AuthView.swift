//
//  AuthView.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 05.05.2026.
//

import SwiftUI

struct AuthView: View {
    @State private var isShowingSignUp = false
    
    private let repository: AuthRepository
    private let signIn: SignInUseCase
    private let signUp: SignUpUseCase
    
    init(repository: AuthRepository = FirebaseAuthRepository()) {
        self.repository = repository
        self.signIn = SignInUseCase(repository: repository)
        self.signUp = SignUpUseCase(repository: repository)
    }
        
    var body: some View {
        ZStack{
            if isShowingSignUp {
                SignUpView(isSignIn: $isShowingSignUp, signUpUseCase: signUp)
                    .transition(.move(edge: .trailing))
            } else {
                SignInView(isSignIn: $isShowingSignUp, signInUseCase: signIn)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.default, value: isShowingSignUp)
    }
}

#Preview {
    AuthView()
}
