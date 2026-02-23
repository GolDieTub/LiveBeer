//
//  InfoStubView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct InfoStubView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Информация")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Экран в разработке")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
