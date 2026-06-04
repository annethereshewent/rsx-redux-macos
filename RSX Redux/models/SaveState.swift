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
    @Attribute(.unique)
    var game: Game?
    var screenshot: Data
    var saveData: Data

    var timestamp: Int

    init(saveName: String, screenshot: [UInt8], saveData: Data, timestamp: Int) {
        self.saveName = saveName
        self.screenshot = Data(screenshot)
        self.saveData = saveData
        self.timestamp = timestamp
    }

    func compare(_ rhs: SaveState) -> Bool {
        return self.timestamp < rhs.timestamp
    }
}
