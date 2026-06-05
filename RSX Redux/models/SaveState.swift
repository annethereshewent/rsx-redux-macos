//
//  SaveState.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import Foundation
import SwiftData

@Model
class SaveState {
    var saveName: String
    var game: Game?
    var screenshot: Data
    var imageWidth: UInt32
    var imageHeight: UInt32
    var saveData: Data

    var timestamp: Int

    init(saveName: String, screenshot: Data, imageWidth: UInt32, imageHeight: UInt32, saveData: Data, timestamp: Int) {
        self.saveName = saveName
        self.screenshot = screenshot
        self.saveData = saveData
        self.timestamp = timestamp
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
    }

    func compare(_ rhs: SaveState) -> Bool {
        return self.timestamp < rhs.timestamp
    }
}
