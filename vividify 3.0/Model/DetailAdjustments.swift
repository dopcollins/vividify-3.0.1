//
//  DetailAdjustments.swift
//  vividify 3.0
//


import Foundation

struct DetailAdjustments: Equatable {

    var brightness: Double = 0
    var contrast: Double = 1
    var saturation: Double = 1
    var warmth: Double = 0
    var shadows: Double = 0

    static let identity = DetailAdjustments()

    /// True when applying these adjustments would leave the image unchanged.
    var isIdentity: Bool { self == .identity }
}
