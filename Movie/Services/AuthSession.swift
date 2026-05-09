//
//  AuthSession.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 05.05.2026.
//

import Combine
import FirebaseAuth
import Foundation
/// Держит текущего пользователя Firebase и обновляет UI при входе/выходе.
final class AuthSession: ObservableObject {
    @Published private(set) var user: User?
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    init() {
        user = Auth.auth().currentUser
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }
    deinit {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }
    func signOut() {
        try? Auth.auth().signOut()
    }
}
