//
//  View.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

extension View {
    func lineHeight(_ value: CGFloat) -> some View {
        self.lineSpacing(max(0, value - UIFont.systemFont(ofSize: UIFont.systemFontSize).lineHeight))
    }
}
