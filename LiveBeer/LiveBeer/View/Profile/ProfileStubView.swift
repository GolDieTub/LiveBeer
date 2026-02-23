//
//  ProfileStubView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct ProfileStubView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Профиль")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Экран в разработке")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
