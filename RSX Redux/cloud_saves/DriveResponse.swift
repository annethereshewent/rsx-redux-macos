//
//  DriveResponse.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/22/26.
//

import Foundation

class DriveResponse : Decodable {
    var files: [File]
}

class File : Decodable {
    var id: String
    var name: String
    var parents: [String]?
    var modifiedTime: String?
}

class FileJSON: Encodable {
    var name: String
    var mimeType: String

    init(name: String, mimeType: String) {
        self.name = name
        self.mimeType = mimeType
    }
}
