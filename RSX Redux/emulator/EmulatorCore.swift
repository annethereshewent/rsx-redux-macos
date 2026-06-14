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
    private var selectedController: UInt8 = 0
    var isRunning = false
    @Published var biosLoaded = false
    @Published var showWaveForm = false
    var gameController: GameController? = nil
    private let emuQueue = DispatchQueue(label: "rsx-redux.emu", qos: .userInteractive)
    private let audioManager = AudioManager()
    var waveFormModel = WaveformModel()
    private var generationId = 0
    private var vibration = false
    private var controllerMode: ControllerMode = .auto
    private var memoryCard: String = "memory_card.mcd"
    private var buttonDict: [UInt16: PressedButton] = [
        KEY_W: .up,
        KEY_S: .down,
        KEY_A: .right,
        KEY_D: .left,

        KEY_I: .triangle,
        KEY_K: .cross,
        KEY_J: .square,
        KEY_L: .circle,

        KEY_ENTER: .start,
        KEY_TAB: .select,

        KEY_U: .l1,
        KEY_O: .r1,
        KEY_7: .l2,
        KEY_9: .r2,

        LEFT_SHIFT: .leftStick,
        RIGHT_SHIFT: .rightStick
    ]


    private var gameUrl: URL?
    private var saveStateUrl: URL?

    init() {
        let metalLayer = CAMetalLayer()
        metalLayer.device = MTLCreateSystemDefaultDevice()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true

        layer = metalLayer

        let userDefaults = UserDefaults.standard

        if userDefaults.object(forKey: "selectedController") != nil {
            self.selectedController = UInt8(userDefaults.integer(forKey: "selectedController"))
        }

        if userDefaults.object(forKey: "vibration") != nil {
            vibration = userDefaults.bool(forKey: "vibration")
        }
        if let memoryCard = userDefaults.string(forKey: "memoryCard") {
            self.memoryCard = memoryCard
        }
        if userDefaults.object(forKey: "playAudio") != nil {
            let playAudio = userDefaults.bool(forKey: "playAudio")
            switchAudio(playAudio)
        }
        if let controllerMode = userDefaults.object(forKey: "controllerMode") {
            do {
                self.controllerMode = try JSONDecoder().decode(ControllerMode.self, from: controllerMode as! Data)
            } catch {
                print(error)
            }
        }

        if let data = userDefaults.object(forKey: "keyDict") {
            do {
                let decoded = try JSONDecoder().decode([PressedButton:KeyBinding].self, from: data as! Data)
                updateBindings(decoded)
            } catch {
                print(error)
            }
        }
    }

    func onKeyInput(_ keyCode: UInt16, _ pressed: Bool) {
        if let button = buttonDict[keyCode] {
            if [.up, .down, .left, .right].contains(button) {
                handleDirectionalButton(button, pressed)
            } else if button == .analog && pressed {
                toggleDigitalMode()
            }  else {
                emulator?.updateInput(button.rawValue, pressed)
            }
        } else if keyCode == KEY_F4 && !pressed {
            showWaveForm.toggle()
        } else if keyCode == KEY_F5 && !pressed {
            saveQuickState()
        } else if keyCode == KEY_F7 && !pressed {
            loadQuickState()
        }
    }

    func handleDirectionalButton(_ button: PressedButton, _ pressed: Bool) {
        if getDigitalMode() {
            updateInput(button, pressed)
        } else {
            switch button {
            case .up:
                let value = pressed ? 0x0 : 0x80
                setLeftY(UInt8(value))
                break
            case .down:
                let value = pressed ? 0xff : 0x80
                setLeftY(UInt8(value))
                break

            case .left:
                let value = pressed ? 0x0 : 0x80
                setLeftX(UInt8(value))
                break
            case .right:
                let value = pressed ? 0xff : 0x80
                setLeftX(UInt8(value))
                break
            default: break
            }
        }
    }

    func updateBindings(_ keyDict: [PressedButton:KeyBinding]) {
        buttonDict = [:]
        for (key, value) in keyDict {
            buttonDict[value.keyCode] = key
        }
    }

    func initialize() {
        generationId += 1

        let ptr = Unmanaged.passUnretained(layer).toOpaque()

        emulator = PsxMacEmulator(ptr)
        emulator!.switchSelectedController(selectedController)
        setControllerMode(controllerMode)
    }

    func switchAudio(_ value: Bool) {
        audioManager.playerPaused = !value
    }

    func startExe(exeUrl: URL) {
        if let emulator = emulator {
            if exeUrl.startAccessingSecurityScopedResource() {
                defer {
                    exeUrl.stopAccessingSecurityScopedResource()
                }

                if !audioManager.isRunning {
                    audioManager.startAudio()
                }

                emulator.startExe(exeUrl.path)

                mainLoop()
            }
        }
    }

    func setMemoryCard(_ card: String) {
        memoryCard = card
    }

    func switchSelectedController(controllerId: UInt8) {
        selectedController = controllerId
        emulator?.switchSelectedController(controllerId)
    }

    func getDigitalMode() -> Bool {
        return emulator?.getDigitalMode() ?? false
    }

    func setDigitalMode(_ value: Bool) {
        emulator?.setDigitalMode(value)
    }

    func setControllerMode(_ controllerMode: ControllerMode) {
        switch controllerMode {
        case .analog:
            emulator?.setDigitalMode(false)
            break
        case .digital:
            emulator?.setDigitalMode(true)
            break
        case .auto: break
        }
    }

    func setVibration(_ vibration: Bool) {
        self.vibration = vibration
    }

    func setMemoryCard() {
        var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("RSX Redux", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            url = url.appendingPathComponent(memoryCard)

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

                    if !audioManager.playerPaused {
                        waveFormModel.push(samples: Array(samples))
                        audioManager.updateBuffer(samples: samples)
                    }

                    if vibration {
                        let (smallMotor, largeMotor) = emulator.getRumble()
                        
                        let smallIntensity: Float = smallMotor ? 0.15 : 0.0
                        let largeIntensity = Float(largeMotor) / 255.0
                        
                        gameController?.handleRumble(smallEngineIntensity: smallIntensity, largeEngineIntensity: largeIntensity)
                    }
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
        print("toggling digital mode!")
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
