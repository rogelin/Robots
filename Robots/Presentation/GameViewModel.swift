//
//  GameViewModel.swift
//  Robots
//

import Foundation
import SwiftUI

final class GameViewModel: ObservableObject {
    var p1 = Player(name: "P1", color: .red)
    var p2 = Player(name: "P2", color: .green)
    @Published var state: [Cell] = []
    @Published var target: Cell?
    
    var canPlay = true
    
    func generateGame() {
        var game: [Cell] = []
        let columns = 1...7
        let rows = 1...7
        rows.forEach { row in
            columns.forEach { column in
                game.append(.init(row: row, column: column))
            }
        }
        self.state = game
        self.generateTarget()
        self.positionPlayers()
        canPlay = true
    }
    
    // 1. At the start of each round, randomly place a prize token somewhere on the game board..
    func generateTarget() {
        self.target = state[Int.random(in: 1...42)]
        self.target?.isTarget = true
    }
    
    // ... and start each robot at opposite corners of the board.
    func positionPlayers() {
        self.state.first { $0.row == 7 && $0.column == 1 }?.owner = p1
        self.state.first { $0.row == 7 && $0.column == 1 }?.isCurrent = true
        self.state.first { $0.row == 1 && $0.column == 7 }?.owner = p2
        self.state.first { $0.row == 1 && $0.column == 7 }?.isCurrent = true
    }
    
    @MainActor
    func move(player: Player) async {
        
        guard
            let target = self.target, // if target was owned by other player in other Thread it will be nil
            let currentCell = self.state.filter({ $0.owner == player && $0.isCurrent }).first
        else {
            return
        }
        print("...and \(player.name) will sync game on \(Thread.current.debugDescription)")
        
        // check distances to the target cell
        let rowOffset = target.row - currentCell.row
        let columnOffset = target.column - currentCell.column
       
        currentCell.isCurrent = false
        
        var ownedCell: Cell?
        
        // Choose the longest path to start (horizontal or vertical)
        if abs(columnOffset) > abs(rowOffset) {
            let nextColumn = columnOffset > 0 ? currentCell.column + 1 : currentCell.column - 1
            ownedCell = self.state.filter({ $0.row == currentCell.row && $0.column == nextColumn }).first
        } else {
            let nextRow = rowOffset > 0 ? currentCell.row + 1 : currentCell.row - 1
            ownedCell =  self.state.filter({ $0.column == currentCell.column && $0.row == nextRow }).first
        }
        
        // Own the cell and set it to current
        withAnimation {
            ownedCell?.owner = player
            ownedCell?.isCurrent = true
        }
        
        // Checks if owned cell is the target, if so player wins.
        if let ownedCell, ownedCell.id == target.id {
            player.score += 1
            self.canPlay.toggle()
            self.target = nil
            print("Game! winner is \(player.name)")
        }
        
        // Forces the Observable object to update
        self.objectWillChange.send()
    }
    
    @MainActor
    func play() {
        
        generateGame()
        
        let semaphore = DispatchSemaphore(value: 1)
        let group = DispatchGroup()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            group.enter()
            guard let self else { return }
            while self.canPlay {
                semaphore.wait()
                print("-----------------------------------------------------------------------------------")
                print("Player \(self.p1.name) from \(Thread.current)")
                Task { await self.move(player: self.p1) }
                sleep(1)
                semaphore.signal()
            }
            group.leave()
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            group.enter()
            guard let self else { return }
            
            while self.canPlay {
                semaphore.wait()
                print("-----------------------------------------------------------------------------------")
                print("Player \(self.p2.name) from \(Thread.current)")
                Task { await self.move(player: self.p2) }
                sleep(1)
                semaphore.signal()
            }
            group.leave()
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            group.wait()
            Task {[weak self] in await self?.play() }
        }
    }
}
