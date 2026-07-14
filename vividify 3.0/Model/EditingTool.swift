//
//  EditingTool.swift
//  vividify 3.0
//


import Foundation

enum EditingTool: String, CaseIterable, Identifiable {

    case crop
    case details
    case tune
    case draw

    var id: String { rawValue }

    var title: String {
        switch self {
        case .crop: "Crop"
        case .details: "Details"
        case .tune: "Tune"
        case .draw: "Draw"
        }
    }

    var systemImage: String {
        switch self {
        case .crop: "crop"
        case .details: "slider.horizontal.3"
        case .tune: "slider.horizontal.below.square.filled.and.square"
        case .draw: "pencil.tip.crop.circle"
        }
    }
}
