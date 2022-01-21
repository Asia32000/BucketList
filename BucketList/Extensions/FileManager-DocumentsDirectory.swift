//
//  FilesManager-DocumentsDirectory.swift
//  BucketList
//
//  Created by Joanna Staleńczyk on 15/01/2022.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
