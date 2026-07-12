//
//  Game.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/3/26.
//

import Foundation
import SwiftData

@Model
class Game {
    @Attribute(.unique)
    var gameName: String
    var gameUrl: URL
    @Relationship(deleteRule: .cascade, inverse: \SaveState.game)
    var saveStates: [SaveState]?
    var lastPlayed: Date

    init(gameName: String, gameUrl: URL, saveStates: [SaveState], lastPlayed: Date) {
        self.gameName = gameName
        self.lastPlayed = lastPlayed
        self.saveStates = saveStates
        self.gameUrl = gameUrl
    }

}
