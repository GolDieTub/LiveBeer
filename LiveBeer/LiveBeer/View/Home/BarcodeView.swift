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
    var quietSpace: CGFloat = 2

    private let context = CIContext()
    private let filter = CIFilter.code128BarcodeGenerator()

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            if let img = makeUIImage(from: payload, targetWidth: w, targetHeight: h) {
                Image(uiImage: img)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()
            } else {
                Color.white
            }
        }
    }

    private func makeUIImage(from string: String, targetWidth: CGFloat, targetHeight: CGFloat) -> UIImage? {
        filter.message = Data(string.utf8)
        filter.quietSpace = Float(quietSpace)
        guard let output = filter.outputImage else { return nil }

        let extent = output.extent.integral
        let baseW = extent.width
        let baseH = extent.height

        let sx = max(1, Int(floor(Double(targetWidth) / Double(baseW))))
        let sy = max(1, Int(floor(Double(targetHeight) / Double(baseH))))

        let scaled = output.transformed(by: CGAffineTransform(scaleX: CGFloat(sx), y: CGFloat(sy)))
        let scaledExtent = scaled.extent.integral

        guard let cg = context.createCGImage(scaled, from: scaledExtent) else { return nil }
        return UIImage(cgImage: cg)
    }
}
