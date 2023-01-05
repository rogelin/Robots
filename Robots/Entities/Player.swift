//
//  Player.swift
//  Robots
//

import Foundation
import SwiftUI

class Player {
    let name: String
    let color: Color
    var score: Int = 0
    
    init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
}

extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name == rhs.name
    }
}
