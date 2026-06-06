//
//  AudioManager.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import Foundation
import AVFoundation
import PSXMacEmulator
import Collections
import DequeModule

let MIN_SAMPLES = 8192 * 2

class AudioManager {
    private let audioEngine = AVAudioEngine()
    private var audioNode: AVAudioSourceNode? = nil
    private let audioFormat = AVAudioFormat(
        commonFormat: .pcmFormatInt16,
        sampleRate: 44100,
        channels: 2,
        interleaved: false
    )
    private let nslock = NSLock()

    private var buffer: Deque<Int16> = []

    private var lastLeft: Int16 = 0
    private var lastRight: Int16 = 0

    var playerPaused: Bool = false

    var isRunning = false

    func startAudio() {
        isRunning = true
        audioNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self, !self.playerPaused && self.isRunning else { return noErr }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)

            let leftPtr = abl[0].mData!.assumingMemoryBound(to: Int16.self)
            let rightPtr = abl[1].mData!.assumingMemoryBound(to: Int16.self)

            nslock.lock()

            for frame in 0..<Int(frameCount) {
                let left = self.buffer.popFirst()
                let right = self.buffer.popFirst()

                if let left {
                    lastLeft = left
                }

                if let right {
                    lastRight = right
                }

                leftPtr[frame] = lastLeft
                rightPtr[frame] = lastRight
            }

            nslock.unlock()

            return noErr
        }
        do {
            self.audioEngine.attach(self.audioNode!)
            self.audioEngine.connect(self.audioNode!, to: self.audioEngine.outputNode, format: self.audioFormat)

            try self.audioEngine.start()
        } catch {
            print(error)
        }
    }

    func updateBuffer(samples: RustVec<Int16>) {
        let samplesCopy = Array(samples)
        if !self.playerPaused {
            nslock.lock()
            self.buffer.append(contentsOf: samplesCopy)
            nslock.unlock()
        }

    }

    func toggleAudio() {
        playerPaused = !playerPaused
    }

    func muteAudio() {
        playerPaused = true
    }

    func resumeAudio() {
        playerPaused = false
    }
}
