//
//  Item.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/2/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
