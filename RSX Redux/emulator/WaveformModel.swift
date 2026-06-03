//
//  WaveformModel.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import Foundation
import Combine


final class WaveformModel: ObservableObject {
    @Published var left: [Float] = Array(repeating: 0, count: 1024)
    @Published var right: [Float] = Array(repeating: 0, count: 1024)

    private let maxSamples = 1024

    func push(samples: [Int16]) {
        var newLeft: [Float] = []
        var newRight: [Float] = []

        var i = 0
        while i + 1 < samples.count {
            newLeft.append(Float(samples[i]) / 32768.0 * 10.0)
            newRight.append(Float(samples[i + 1]) / 32768.0 * 10.0)
            i += 2
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.left.append(contentsOf: newLeft)
            self.right.append(contentsOf: newRight)

            if self.left.count > maxSamples {
                self.left.removeFirst(self.left.count - maxSamples)
            }
            if self.right.count > maxSamples {
                self.right.removeFirst(self.right.count - maxSamples)
            }
        }
    }
}
