//
//  SFSymbolName.swift
//  SmartSearchExample
//
//  Created by Geoff Hackworth on 23/01/2021.
//

import Foundation

/// SF Symbol name.
///
/// Simple type safe wrapper around `String`.
struct SFSymbolName: RawRepresentable, Hashable {
    var rawValue: String
}
