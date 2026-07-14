//
//  TuneAdjustments.swift
//  vividify 3.0
//

import Foundation

struct TuneAdjustments: Equatable {

    var smoothness: Double = 0
    var sharpness: Double = 0

    static let identity = TuneAdjustments()

    var isIdentity: Bool { self == .identity }
}
