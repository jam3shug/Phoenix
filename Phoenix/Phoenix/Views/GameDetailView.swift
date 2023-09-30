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
    @State var playColor = Color.green
    @State var settingsColor = Color.gray.opacity(0.1)
    @State var playText = Color.white
    @State var settingsText = Color.primary

    init(selectedGame: Binding<String?>, refresh: Binding<Bool>, editingGame: Binding<Bool>, playingGame: Binding<Bool>) {
        _selectedGame = selectedGame
        _refresh = refresh
        _editingGame = editingGame
        _playingGame = playingGame
    }

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                    let game = games[idx]

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
            }.frame(height: 400)

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            // play button
                            LargeToggleButton(toggle: $playingGame, symbol: "play.fill", text: "Play", textColor: playText, bgColor: playColor)
                            .alert(
                                "No launcher configured. Please configure a launch command to run \(selectedGame ?? "this game")",
                                isPresented: $showingAlert
                            ) {}
                            
                            // settings button
                            SmallToggleButton(toggle: $editingGame, symbol: "pencil", textColor: settingsText, bgColor: settingsColor)
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
                            // description
                            TextCard(content: {
                                if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                                    let game = games[idx]
                                    // Game Description
                                    if game.metadata["description"] != "" {
                                        Text(game.metadata["description"] ?? "No game selected")
                                            .font(.system(size: 14.5))
                                            .lineSpacing(3.5)
                                            .padding(10)
                                    } else {
                                        Text("No description found")
                                            .font(.system(size: 14.5))
                                            .lineSpacing(3.5)
                                            .padding(10)
                                    }
                                }
                            })
                            .frame(idealWidth: 400, maxWidth: 550, maxHeight: .infinity, alignment: .topLeading) // controls the dimensions and alignment of the description text
                            .padding(.trailing, 7.5)
                            VStack(alignment: .leading) {
                                if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                                    let game = games[idx]
                                    VStack(alignment: .leading, spacing: 7.5) {
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Last Played")
                                            Text(game.metadata["last_played"] ?? "Never")
                                                .opacity(0.5)
                                        }
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Platform")
                                            Text(game.platform.displayName)
                                                .opacity(0.5)
                                        }
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Status")
                                            Text(game.status.displayName)
                                                .opacity(0.5)
                                        }
                                        if game.metadata["rating"] != "" {
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Rating")
                                                Text(game.metadata["rating"] ?? "")
                                                    .opacity(0.5)
                                            }
                                        }
                                        if game.metadata["genre"] != "" {
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Genres")
                                                Text(game.metadata["genre"] ?? "")
                                                    .opacity(0.5)
                                            }
                                        }
                                        if game.metadata["developer"] != "" {
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Developer")
                                                Text(game.metadata["developer"] ?? "")
                                                    .opacity(0.5)
                                            }
                                        }
                                        if game.metadata["publisher"] != "" {
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Publisher")
                                                Text(game.metadata["publisher"] ?? "")
                                                    .opacity(0.5)
                                            }
                                        }
                                        if game.metadata["release_date"] != "" {
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Release Date")
                                                Text(game.metadata["release_date"] ?? "")
                                                    .opacity(0.5)
                                            }
                                        }
                                    }
                                    .padding(.trailing, 10)
                                    .frame(minWidth: 150, alignment: .leading)
                                }
                            }
                            .font(.system(size: 14.5))
                            .padding(10)
                            .background(Color.gray.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7.5)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(7.5)
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
                refreshGameDetailView()
                refresh.toggle()
                // This code will be executed every 1 second
            }
        }
        .onDisappear {
            // Invalidate the timer when the view disappears
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: playingGame) { _ in
            let idx = games.firstIndex(where: { $0.name == selectedGame })
            let game = games[idx!]
            playGame(game: game)
        }
        .toast(isPresenting: $showSuccessToast, tapToDismiss: true) {
            AlertToast(type: .complete(Color.green), title: "Game edited.")
        }
    }
    
    func refreshGameDetailView() {
        if UserDefaults.standard.bool(forKey: "accentColorUI") {
            playColor = Color.accentColor
            settingsColor = Color.accentColor.opacity(0.25)
            settingsText = Color.accentColor
        } else {
            playColor = Color.green
            settingsColor = Color.gray.opacity(0.25)
            settingsText = Color.primary
        }
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

