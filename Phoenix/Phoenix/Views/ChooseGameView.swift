//
//  ChooseGameView.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import SwiftUI
import IGDB_SWIFT_API
import Kingfisher

struct ChooseGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var games: [Proto_Game]
    @State var selectedGame: Proto_Game?
    @Binding var fetchedGame: Game?
    
    var body: some View {
        VStack {
            List(selection: $selectedGame) {
                ForEach(games.sorted { $0.id < $1.id }, id: \.self) { game in
                    HStack(spacing: 20) {
                        KFImage(URL(string: imageBuilder(imageID: game.cover.imageID, size: .COVER_BIG, imageType: .JPEG)))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .cornerRadius(5)
                        VStack {
                            Text(game.name) // UNCENTER ThIS TEXT
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                            Text(game.summary) //SHORTEN THIS TEXT TO 2 LINES
                                .font(.caption)
                                .lineLimit(3)
                        }
                    }
                }
            }
            Button(
                action: {
                    if let selectedGame = selectedGame, let fetchedGame = fetchedGame {
                        FetchGameData().convertIGDBGame(igdbGame: selectedGame, userGame: fetchedGame)
                    }
                    dismiss()
                },
                label: {
                    Text("Select Game")
                }
            )
        }
        .padding()
        .frame(minWidth: 720, minHeight: 250, idealHeight: 400)
    }
}

