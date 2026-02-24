//
//  BubbleWithArrowShape.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct BubbleWithArrowShape: Shape {
    var arrowWidth: CGFloat
    var arrowHeight: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let aw = min(arrowWidth, rect.width * 0.6)
        let ah = min(arrowHeight, rect.height * 0.3)
        let r = min(cornerRadius, min(rect.width, rect.height - ah) / 2)

        let bubbleRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - ah)

        let axMid = rect.midX
        let axLeft = axMid - aw / 2
        let axRight = axMid + aw / 2
        let ayTop = bubbleRect.maxY
        let ayTip = rect.maxY

        var p = Path()

        p.move(to: CGPoint(x: bubbleRect.minX + r, y: bubbleRect.minY))

        p.addLine(to: CGPoint(x: bubbleRect.maxX - r, y: bubbleRect.minY))
        p.addArc(
            center: CGPoint(x: bubbleRect.maxX - r, y: bubbleRect.minY + r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bubbleRect.maxX, y: bubbleRect.maxY - r))
        p.addArc(
            center: CGPoint(x: bubbleRect.maxX - r, y: bubbleRect.maxY - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: axRight, y: ayTop))
        p.addLine(to: CGPoint(x: axMid, y: ayTip))
        p.addLine(to: CGPoint(x: axLeft, y: ayTop))

        p.addLine(to: CGPoint(x: bubbleRect.minX + r, y: bubbleRect.maxY))
        p.addArc(
            center: CGPoint(x: bubbleRect.minX + r, y: bubbleRect.maxY - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        p.addLine(to: CGPoint(x: bubbleRect.minX, y: bubbleRect.minY + r))
        p.addArc(
            center: CGPoint(x: bubbleRect.minX + r, y: bubbleRect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        p.closeSubpath()
        return p
    }
}
