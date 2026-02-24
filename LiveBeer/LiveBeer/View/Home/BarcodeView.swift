//
//  BarcodeView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BarcodeView: View {
    let payload: String

    private let context = CIContext()
    private let filter = CIFilter.code128BarcodeGenerator()

    var body: some View {
        if let img = makeUIImage(from: payload) {
            Image(uiImage: img)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
        } else {
            Color.white
        }
    }

    private func makeUIImage(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.message = data
        filter.quietSpace = 7
        guard let outputImage = filter.outputImage else { return nil }

        let transform = CGAffineTransform(scaleX: 3.5, y: 6.0)
        let scaled = outputImage.transformed(by: transform)

        guard let cgimg = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgimg)
    }
}
