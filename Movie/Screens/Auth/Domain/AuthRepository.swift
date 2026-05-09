//
//  AuthRepository.swift
//  Movie
//
//  Created by ekaterina.shevchenko on 09.05.2026.
//

import Foundation

//domain- говорит, что нужно уметь вход/регистрацию не уточняя как (Firebase,Rest)

protocol AuthRepository {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
}
