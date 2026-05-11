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
    private let bioCoordinator: BioAuthCoordinator

    init(repository: AuthRepository = FirebaseAuthRepository()) {
        self.repository = repository
        let firebaseForBio = FirebaseAuthRepository()
        self.signIn = SignInUseCase(repository: repository)
        self.signUp = SignUpUseCase(repository: repository)
        self.bioCoordinator = BioAuthCoordinator(authRepository: firebaseForBio)
    }
        
    var body: some View {
        ZStack{
            if isShowingSignUp {
                SignUpView(isSignIn: $isShowingSignUp, signUpUseCase: signUp)
                    .transition(.move(edge: .trailing))
            } else {
                SignInView(isSignIn: $isShowingSignUp, signInUseCase: signIn, bioCoordinator: bioCoordinator)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.default, value: isShowingSignUp)
    }
}

#Preview {
    AuthView()
}
