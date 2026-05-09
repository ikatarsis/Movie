//
//  ProfileMenuView.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 07.05.2026.
//

import SwiftUI
import FirebaseAuth

struct ProfileMenuView: View {
    @EnvironmentObject var authVM: AuthSession
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundStyle(.blue)
            VStack(spacing: 4) {
                Text("Ваш аккаунт")
                    .font(.callout)
                Text(authVM.user?.email ?? "Email не указан")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button("Выйти") {
                authVM.signOut()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 2)
        }
        .padding()
    }
}

#Preview {
    ProfileMenuView()
            .environmentObject(AuthSession())
}
