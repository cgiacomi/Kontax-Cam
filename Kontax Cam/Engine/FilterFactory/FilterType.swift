//
//  FilterType.swift
//  Kontax Cam
//
//  Created by Kevin Laminto on 13/6/20.
//  Copyright © 2020 Kevin Laminto. All rights reserved.
//

import Foundation

enum FilterType: Int, CaseIterable {
    case lut, grain, dust
}

extension FilterType: CustomStringConvertible {
    var description: String {
      get {
        switch self {
        case .lut: return "LUT"
        case .grain: return "Grain"
        case .dust: return "Dust"
        }
      }
    }
}

extension FilterType: Equatable {
    static func < (rhs: FilterType, lhs: FilterType) -> Bool {
        return rhs.rawValue < lhs.rawValue
    }
    
    static func > (rhs: FilterType, lhs: FilterType) -> Bool {
        return rhs.rawValue > lhs.rawValue
    }
}