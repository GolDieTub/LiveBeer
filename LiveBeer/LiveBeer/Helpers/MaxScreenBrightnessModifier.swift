//
//  MaxScreenBrightnessModifier.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI
import UIKit

private final class ScreenCapturingView: UIView {
    var onScreenChange: ((UIScreen?) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onScreenChange?(window?.windowScene?.screen)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        onScreenChange?(window?.windowScene?.screen)
    }
}

private struct ScreenCaptureRepresentable: UIViewRepresentable {
    @Binding var screen: UIScreen?

    func makeUIView(context: Context) -> ScreenCapturingView {
        let view = ScreenCapturingView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.onScreenChange = { newScreen in
            DispatchQueue.main.async {
                self.screen = newScreen
            }
        }
        return view
    }

    func updateUIView(_ uiView: ScreenCapturingView, context: Context) {
        uiView.onScreenChange?(uiView.window?.windowScene?.screen)
    }
}

private struct MaxScreenBrightnessModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var previousBrightness: CGFloat?
    @State private var screen: UIScreen?

    func body(content: Content) -> some View {
        content
            .background(ScreenCaptureRepresentable(screen: $screen).frame(width: 0, height: 0))
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    if previousBrightness == nil {
                        previousBrightness = screen?.brightness
                    }
                    if let s = screen {
                        s.brightness = 1.0
                    }
                } else {
                    restore()
                }
            }
            .onAppear {
                if isPresented {
                    if previousBrightness == nil {
                        previousBrightness = screen?.brightness
                    }
                    if let s = screen {
                        s.brightness = 1.0
                    }
                }
            }
            .onDisappear {
                restore()
            }
    }

    private func restore() {
        if let prev = previousBrightness, let s = screen {
            s.brightness = prev
        }
        previousBrightness = nil
    }
}

extension View {
    func maxScreenBrightnessWhilePresented(isPresented: Binding<Bool>) -> some View {
        modifier(MaxScreenBrightnessModifier(isPresented: isPresented))
    }
}
