//
//  EmulatorCore.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//
import Foundation
import MetalKit
import PSXMacEmulator
import Combine
import GameController

class StateInfo {
    var saveData: Data
    var screenshot: Data
    var width: UInt32
    var height: UInt32

    init(_ saveData: Data, _ screenshot: Data, _ width: UInt32, _ height: UInt32) {
        self.saveData = saveData
        self.screenshot = screenshot
        self.width = width
        self.height = height
    }
}

class EmulatorCore: ObservableObject {
    @Published private(set) var layer: CAMetalLayer
    private var initialized = false
    private var emulator: PsxMacEmulator?
    var isRunning = false
    @Published var biosLoaded = false
    @Published var showWaveForm = false
    var gameController: GameController? = nil
    private let emuQueue = DispatchQueue(label: "rsx-redux.emu", qos: .userInteractive)
    private let audioManager = AudioManager()
    var waveFormModel = WaveformModel()
    private var generationId = 0

    private var gameUrl: URL?
    private var saveStateUrl: URL?

    init() {
        let metalLayer = CAMetalLayer()
        metalLayer.device = MTLCreateSystemDefaultDevice()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true

        layer = metalLayer
    }

    func initialize() {
        generationId += 1

        let ptr = Unmanaged.passUnretained(layer).toOpaque()

        emulator = PsxMacEmulator(ptr)
    }

    func startExe(exeUrl: URL) {
        if let emulator = emulator {
            if exeUrl.startAccessingSecurityScopedResource() {
                defer {
                    exeUrl.stopAccessingSecurityScopedResource()
                }
                
                emulator.startExe(exeUrl.path)

                mainLoop()
            }
        }
    }

    func getDigitalMode() -> Bool {
        return emulator?.getDigitalMode() ?? false
    }

    func setDigitalMode(_ value: Bool) {
        emulator?.setDigitalMode(value)
    }

    func setMemoryCard() {
        var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("RSX Redux", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            url = url.appendingPathComponent("memory_card.mcd")

            if !FileManager.default.fileExists(atPath: url.path) {
                FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
            }

            emulator?.setMemoryCard(url.path)
        } catch {
            print(error)
        }
    }

    func startEmulator(gameUrl: URL) {
        if let emulator = emulator {
            if gameUrl.startAccessingSecurityScopedResource() {
                defer {
                    gameUrl.stopAccessingSecurityScopedResource()
                }

                setMemoryCard()

                if !audioManager.isRunning {
                    audioManager.startAudio()
                }

                let gamePath = gameUrl.path
                self.gameUrl = gameUrl
                emulator.loadRom(gamePath)

                mainLoop()
            }
        }
    }

    func stopEmulatorThen(_ block: @escaping () -> Void) {
        isRunning = false
        generationId += 1

        emuQueue.async {
            block()
        }
    }

    func mainLoop() {
        if let emulator = emulator {
            self.isRunning = true
            emuQueue.async { [weak self] in
                guard let self else { return }

                let currGeneration = self.generationId

                while isRunning && currGeneration == self.generationId {
                    emulator.stepFrame()

                    let samples = emulator.drainSamples()

                    waveFormModel.push(samples: Array(samples))
                    audioManager.updateBuffer(samples: samples)

                    let (smallMotor, largeMotor) = emulator.getRumble()

                    let smallIntensity: Float = smallMotor ? 0.15 : 0.0
                    let largeIntensity = Float(largeMotor) / 255.0

                    gameController?.handleRumble(smallEngineIntensity: smallIntensity, largeEngineIntensity: largeIntensity)
                }
            }
        }
    }

    func stepFrame() {
        emulator?.stepFrame()
    }

    func loadBios(biosUrl: URL) {
        let biosPath = biosUrl.path

        emulator?.loadBios(biosPath)
        DispatchQueue.main.async {
            self.biosLoaded = true
        }
    }

    func toggleDigitalMode() {
        emulator?.toggleDigitalMode()
    }

    func updateInput(_ button: PressedButton, _ pressed: Bool) {
        emulator?.updateInput(button.rawValue, pressed)
    }

    func setLeftThumbstick(_ normalizedX: UInt8, _ normalizedY: UInt8) {
        emulator?.setLeftThumbstick(normalizedX, normalizedY)
    }

    func setLeftX(_ normalizedX: UInt8) {
        emulator?.setLeftX(normalizedX)
    }

    func setLeftY(_ normalizedY: UInt8) {
        emulator?.setLeftY(normalizedY)
    }

    func setRightThumbstick(_ normalizedX: UInt8, _ normalizedY: UInt8) {
        emulator?.setRightThumbstick(normalizedX, normalizedY)
    }

    func loadQuickState() {
        if let url = saveStateUrl ?? getQuickStateUrl() {
            stopEmulatorThen {
                if self.gameUrl?.startAccessingSecurityScopedResource() ?? false {
                    defer {
                        self.gameUrl?.stopAccessingSecurityScopedResource()
                    }
                    do {
                        let data = try Data(contentsOf: url)


                        Array(data).withUnsafeBufferPointer { ptr in
                            self.emulator?.loadState(ptr)

                            self.mainLoop()
                        }

                    } catch {
                        print(error)
                    }
                }
            }
        }
    }

    func loadState(data: Data) {
        stopEmulatorThen {
            if self.gameUrl?.startAccessingSecurityScopedResource() ?? false {
                defer {
                    self.gameUrl?.stopAccessingSecurityScopedResource()
                }

                Array(data).withUnsafeBufferPointer { ptr in
                    self.emulator?.loadState(ptr)

                    self.mainLoop()
                }
            }
        }
    }

    func getQuickStateUrl() -> URL? {
        var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("RSX Redux", isDirectory: true)
        if let saveStateDir = gameUrl?.deletingPathExtension().lastPathComponent {
            url = url.appendingPathComponent(saveStateDir, isDirectory: true).appendingPathComponent("quick_save.state")

            return url
        }

        return nil
    }

    func saveQuickState() {
        if let dataVec = emulator?.saveState() {
            let data = Data(Array(dataVec))

            var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("RSX Redux", isDirectory: true)
            if let saveStateDir = gameUrl?.deletingPathExtension().lastPathComponent {
                url = url.appendingPathComponent(saveStateDir, isDirectory: true)

                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                    url = url.appendingPathComponent("quick_save.state")

                    try data.write(to: url)

                    saveStateUrl = url
                } catch {
                    print(error)
                }
            }
        }
    }

    func saveState() -> StateInfo? {
        if let emulator = emulator {
            isRunning = false

            let screenshot = emulator.getScreenshot()
            let (width, height) = emulator.getDimensions()

            let screenshotArr = Array(screenshot)

            let stateVec = emulator.saveState()

            mainLoop()

            return StateInfo(Data(Array(stateVec)), Data(screenshotArr), width, height)
        }

        return nil
    }
}
