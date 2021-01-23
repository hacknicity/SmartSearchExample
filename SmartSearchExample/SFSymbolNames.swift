//
//  SFSymbolNames.swift
//  SmartSearchExample
//
//  Created by Geoff Hackworth on 23/01/2021.
//

import Foundation

final class SFSymbolNames {

    /// Array of `SFSymbolNames` read from `SFSymbols.txt` and sorted alphabetically.
    static let all: [SFSymbolName] = {
        guard let url = Bundle.main.url(forResource: "SFSymbols", withExtension: "txt") else {
            fatalError("cannot create URL for SFSymbols.txt")
        }

        guard let string = try? String(contentsOf: url) else {
            fatalError("cannot read SFSymbols.txt")
        }

        // Split contents of file into an array of `SFSymbolName`s, sorted alphabetically
        return string
            .split(separator: "\n")
            .sorted()
            .map { SFSymbolName(value: String($0)) }
    }()
}
