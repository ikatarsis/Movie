//
//  AuthView.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 05.05.2026.
//

import SwiftUI

struct AuthView: View {
    @State private var isSignIn = false
    
    var body: some View {
        ZStack{
            if isSignIn {
                SignUp(isSignIn: $isSignIn)
                    .transition(.move(edge: .trailing))
            } else {
                SignIn(isSignIn: $isSignIn)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.default, value: isSignIn)
    }
}

#Preview {
    AuthView()
}
