//
//  GameView.swift
//  Robots
//

import SwiftUI

struct GameView: View {
    
    @StateObject var viewModel = GameViewModel()
    
    var layout = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                HStack {
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(viewModel.p1.color)
                    Text(viewModel.p1.score.description)
                        .foregroundColor(viewModel.p1.color)
                        .font(.title)
                    Spacer()
                    Text(viewModel.p2.score.description)
                        .foregroundColor(viewModel.p2.color)
                        .font(.title)
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(viewModel.p2.color)
                }
                LazyVGrid(columns: layout) {
                    ForEach(viewModel.state) { cell in
                        ZStack {
                            Circle()
                                .foregroundColor(cell.cellColor)
                                .animation(.spring(), value: 2)
                            if cell.isTarget {
                                Circle()
                                    .foregroundColor(.yellow)
                                    .padding(4)
                            }
                        }
                    }
                }
                .animation(.easeInOut, value: 1)
            }
            .padding(30)
            .onAppear {
                viewModel.play()
            }
            Spacer()
        }
        .background(Color.black)
        .ignoresSafeArea(.all)
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
