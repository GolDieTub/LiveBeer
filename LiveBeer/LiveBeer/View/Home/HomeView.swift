//
//  HomeView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct HomeView: View {
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Главная")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Пользователь вошёл")
                .foregroundStyle(.secondary)
            Button("Выйти") {
                onLogout()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
