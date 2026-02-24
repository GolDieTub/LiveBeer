//
//  UnauthorizedViewModel.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

@MainActor
final class UnauthorizedViewModel: ObservableObject {
    
    private let onLoginTap: () -> Void

    init(onLoginTap: @escaping () -> Void) {
        self.onLoginTap = onLoginTap
    }

    func loginTapped() {
        onLoginTap()
    }
}
