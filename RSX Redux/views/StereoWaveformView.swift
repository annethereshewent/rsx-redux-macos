//
//  StereoWaveformView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import SwiftUI

struct StereoWaveformView: View {
    @ObservedObject var model: WaveformModel

    var body: some View {
        Canvas { context, size in
            drawWaveform(
                samples: model.left,
                in: CGRect(x: 0, y: 0, width: size.width, height: size.height / 2),
                context: &context
            )

            drawWaveform(
                samples: model.right,
                in: CGRect(x: 0, y: size.height / 2, width: size.width, height: size.height / 2),
                context: &context
            )
        }
        .frame(height: 320)
    }

    private func drawWaveform(
        samples: [Float],
        in rect: CGRect,
        context: inout GraphicsContext
    ) {
        guard samples.count > 1 else { return }

        var path = Path()
        let midY = rect.midY
        let xStep = rect.width / CGFloat(samples.count - 1)

        path.move(to: CGPoint(x: rect.minX, y: midY))

        for i in samples.indices {
            let x = rect.minX + CGFloat(i) * xStep
            let y = midY - CGFloat(samples[i]) * (rect.height / 2)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        context.stroke(path, with: .color(.green), lineWidth: 1)
    }
}
