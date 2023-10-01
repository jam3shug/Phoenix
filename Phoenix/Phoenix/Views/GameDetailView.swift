//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI
import AlertToast

struct GameDetailView: View {
    
    @State var showingAlert: Bool = false
    @Binding var selectedGame: String?
    @Binding var refresh: Bool
    @Binding var editingGame: Bool
    @Binding var playingGame: Bool
    @State var showSuccessToast: Bool = false
    
    @State private var timer: Timer?

    // initialize colors
    @State var bgPlayColor = Color.green
    @State var bgSettingsColor = Color.gray.opacity(0.1)
    @State var textPlayColor = Color.white
    @State var textSettingsColor = Color.primary

    init(selectedGame: Binding<String?>, refresh: Binding<Bool>, editingGame: Binding<Bool>, playingGame: Binding<Bool>) {
        _selectedGame = selectedGame
        _refresh = refresh
        _editingGame = editingGame
        _playingGame = playingGame
    }

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                let game = getGameFromName(name: selectedGame ?? "")
                if let game = game {
                    // create header image
                    Image(nsImage: loadImageFromFile(filePath: (game.metadata["header_img"]?.replacingOccurrences(of: "\\", with: ":"))!))
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width, height: getHeightForHeaderImage(geometry)
                        )
                        .blur(radius: getBlurRadiusForImage(geometry))
                        .clipped()
                        .offset(x: 0, y: getOffsetForHeaderImage(geometry))
                }
            }
            .frame(height: 400)
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            // play button
                            LargeToggleButton(toggle: $playingGame, symbol: "play.fill", text: "Play", textColor: textPlayColor, bgColor: bgPlayColor)
                            .alert(
                                "No launcher configured. Please configure a launch command to run \(selectedGame ?? "this game")",
                                isPresented: $showingAlert
                            ) {}
                            
                            // settings button
                            SmallToggleButton(toggle: $editingGame, symbol: "pencil", textColor: textSettingsColor, bgColor: bgSettingsColor)
                            .sheet(
                                isPresented: $editingGame,
                                onDismiss: {
                                    // Refresh game list
                                    refresh.toggle()
                                },
                                content: {
                                    GameInputView(isNewGame: false, gameName: selectedGame ?? "", showSuccessToast: $showSuccessToast)
                                }
                            )
                        } // hstack
                        .frame(alignment: .leading)

                        HStack(alignment: .top) {
                            //description
                            VStack(alignment: .leading) {
                                let game = getGameFromName(name: selectedGame ?? "")
                                if game?.metadata["description"] != "" {
                                    TextCard(text: game?.metadata["description"] ?? "No game selected")
                                } else {
                                    TextCard(text: "No description found.")
                                }
                            }
                            .padding(.trailing, 7.5)
                            
                            SlotCard(content: {
                                let game = getGameFromName(name: selectedGame ?? "")
                                if let game = game {
                                    VStack(alignment: .leading, spacing: 7.5) {
                                        GameMetadata(field: "Last Played", value: game.metadata["last_played"] ?? "Never")
                                        GameMetadata(field: "Platform", value: game.platform.displayName)
                                        GameMetadata(field: "Status", value: game.status.displayName)
                                        GameMetadata(field: "Rating", value: game.metadata["rating"] ?? "")
                                        GameMetadata(field: "Genres", value: game.metadata["genre"] ?? "")
                                        GameMetadata(field: "Developer", value: game.metadata["developer"] ?? "")
                                        GameMetadata(field: "Publisher", value: game.metadata["publisher"] ?? "")
                                        GameMetadata(field: "Release Date", value: game.metadata["release_date"] ?? "")
                                    }
                                    .padding(.trailing, 10)
                                    .frame(minWidth: 150, alignment: .leading)
                                }
                            })
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.top, 10)
                    }
                    .padding(EdgeInsets(top: 10, leading: 17.5, bottom: 10, trailing: 17.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle(selectedGame ?? "Phoenix")
        .onAppear {
            // Usage
            refreshGameDetailView()
            if selectedGame == nil {
                selectedGame = games[0].name
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // This code will be executed every 1 second
                refresh.toggle()
            }
        }
        .onDisappear {
            // Invalidate the timer when the view disappears
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: playingGame) { _ in
            let game = getGameFromName(name: selectedGame ?? "")
            if let game = game {
                playGame(game: game)
            }
        }
        .onChange(of: UserDefaults.standard.bool(forKey: "accentColorUI")) { _ in
            refreshGameDetailView()
        }
        .toast(isPresenting: $showSuccessToast, tapToDismiss: true) {
            AlertToast(type: .complete(Color.green), title: "Game Edited!")
        }
    }
    
    func refreshGameDetailView() {
        if UserDefaults.standard.bool(forKey: "accentColorUI") {
            bgPlayColor = Color.accentColor
            bgSettingsColor = Color.accentColor.opacity(0.25)
            textSettingsColor = Color.accentColor
        } else {
            bgPlayColor = Color.green
            bgSettingsColor = Color.gray.opacity(0.25)
            textSettingsColor = Color.primary
        }
        refresh.toggle()
    }
    
    func playGame(game: Game) {
        do {
            let currentDate = Date()
            // Update the last played date and write the updated information to the JSON file
            updateLastPlayedDate(currentDate: currentDate, games: &games)
            if game.launcher != "" {
                try shell(game)
            } else {
                showingAlert = true
            }
        } catch {
            logger.write("\(error)") // handle or silence the error here
        }
        
    }

    func updateLastPlayedDate(currentDate: Date, games: inout [Game]) {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()

        // Convert the current date to a string using the dateFormatter
        let dateString = dateFormatter.string(from: currentDate)

        // Update the value of "last_played" in the game's metadata
        let idx = games.firstIndex(where: { $0.name == selectedGame })
        if idx != nil {
            games[idx!].metadata["last_played"] = dateString
            games[idx!].recency = .day

            // Write the updated game information to the JSON file
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            do {
                let gamesJSON = try encoder.encode(games)

                if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                    // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                    gamesJSONString = "{\"games\": \(gamesJSONString)}"
                    writeGamesToJSON(data: gamesJSONString)
                }
            } catch {
                logger.write(error.localizedDescription)
            }
        }
    }
}

