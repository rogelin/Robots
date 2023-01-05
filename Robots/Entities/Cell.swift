//
//  Cell.swift
//  Robots
//

import Foundation
import SwiftUI

class Cell {
    var cellColor: Color {
        
        if let owner {
            return isCurrent ? owner.color : owner.color.opacity(0.3)
        }
        
        return isTarget ? .yellow : .gray.opacity(8.0)
    }
    let row: Int
    let column: Int
    var owner: Player?
    var isCurrent = false
    var isTarget = false
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

extension Cell: Identifiable {
    var id: String {
        return "[\(column),\(row)]"
    }
}

extension Cell: Equatable {
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.row == rhs.row
        && lhs.column == rhs.column
    }
}
