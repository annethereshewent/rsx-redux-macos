//
//  SaveStateView.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import SwiftUI

struct SaveStateView: View {
    @Binding var currentGame: Game?
    @EnvironmentObject private var emulatorCore: EmulatorCore

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 200))
                ],
                spacing: 16
            ) {
                let saveStates = currentGame?.saveStates ?? []
                ForEach(saveStates) { saveState in
                    let nsImage = imageFromRGBA(saveState.screenshot, width: Int(saveState.imageWidth), height: Int(saveState.imageHeight)) ?? NSImage()
                    Button() {
                        emulatorCore.loadState(data: saveState.saveData)
                    } label: {
                        VStack {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 160, height: 120)
                            Text(saveState.saveName)
                        }
                    }

                }
            }
        }
    }

    func imageFromRGBA(_ data: Data, width: Int, height: Int) -> NSImage? {
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = width * bytesPerPixel

        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }

        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bytesPerPixel * bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }
}
