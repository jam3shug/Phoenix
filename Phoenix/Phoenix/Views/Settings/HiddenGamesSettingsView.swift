//
//  HiddenGamesSettingsView.swift
//  Phoenix
//
//  Created by james hughes on 6/18/23.
//

import SwiftUI

struct HiddenGamesSettingsView: View {
    
    @State var selectedGame: String?
    @Binding var refresh: Bool = false
    
    var body: some View {
        VStack {
            List(selection: $selectedGame) {
                ForEach(Platform.allCases, id: \.self) { platform in
                    let gamesForPlatform = games.filter { $0.platform == platform && $0.isHidden == true}
                    if !gamesForPlatform.isEmpty {
                        Section(header: Text(platform.displayName)) {
                            ForEach(gamesForPlatform, id: \.id) { game in
                                HStack {
                                    Image(nsImage: loadImageFromFile(filePath: game.icon))
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                    Text(game.name)
                                }
                                .contextMenu {
                                    Button(action: {
                                        if let idx = games.firstIndex(where: { $0.id == game.id }) {
                                            games[idx].isHidden = false
                                        }
                                        $refresh.toggle()
                                        saveGames()
                                    }) {
                                        Text("Show game")
                                    }
                                    .accessibility(identifier: "Show Game")
                                }
                            }.scrollDisabled(true)
                        }
                    }
                }
            }
        }
    }
}
