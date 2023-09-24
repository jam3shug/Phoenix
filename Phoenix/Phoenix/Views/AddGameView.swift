//
//  AddGameView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-27.
//
import Foundation
import SwiftUI
import IGDB_SWIFT_API
import AlertToast

struct AddGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    @Binding var showAddedGameToast: Bool
    @State private var showDupeGameToast = false
    
    @State private var showChooseGameView: Bool = false
    
    @State var fetchedGames: [Proto_Game] = []
    @State var fetchedGame: Game?
    
    @State private var nameInput: String = ""
    @State private var iconOutput: String = ""
    @State private var platInput: Platform = .none
    @State private var statusInput: Status = .none
    @State private var cmdInput: String = ""
    @State private var descInput: String = ""
    @State private var headOutput: String = ""
    @State private var rateInput: String = ""
    @State private var genreInput: String = ""
    @State private var devInput: String = ""
    @State private var pubInput: String = ""
    @State private var dateInput: Date = .now

    @State private var iconIsImporting: Bool = false
    @State private var headIsImporting: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    TextBox(textBoxName: "Name", placeholder: "Enter game name", input: $nameInput) // Name input
                    
                    ImageImportButton(type: "Icon", isImporting: $iconIsImporting, output: $iconOutput, gameName: nameInput) 
        
                    SlotInput(contentName: "Platform", content: {
                        Picker("", selection: $platInput) {
                            ForEach(Platform.allCases) { platform in
                                Text(platform.displayName)
                            }
                        }
                    })
                    
                    SlotInput(contentName: "Status", content: {
                        Picker("", selection: $statusInput) {
                            ForEach(Status.allCases) { status in
                                Text(status.displayName)
                            }
                        }
                    })
                    
                    TextBox(textBoxName: "Command", placeholder: "Enter terminal command to launch game", input: $cmdInput)
                }
                DisclosureGroup("Metadata (automatically fetched by default)") {
                    VStack(alignment: .leading) {
                        LargeTextBox(textBoxName: "Description", input: $descInput)
                        
                        LargeTextBox(textBoxName: "Genres", input: $genreInput)
                        
                        ImageImportButton(type: "Header", isImporting: $headIsImporting, output: $headOutput, gameName: nameInput)
                        
                        TextBox(textBoxName: "Rating", placeholder: "X / 10", input: $rateInput)
                        
                        TextBox(textBoxName: "Developer", placeholder: "Enter game developer", input: $devInput)
                        
                        TextBox(textBoxName: "Publisher", placeholder: "Enter game publisher", input: $pubInput)
                        
                        SlotInput(contentName: "Release Date", content: {
                            DatePicker("", selection: $dateInput, in: ...Date(), displayedComponents: .date)
                        })
                    }
                }
            }
            .padding()
            HStack {
                Spacer().frame(maxWidth: .infinity)
                Button(
                    action: {
                        let dateFormatter: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .long
                            return formatter
                        }()
                        
                        let newGame: Game = .init(
                            launcher: cmdInput,
                            metadata: [
                                "description": descInput,
                                "header_img": headOutput,
                                "last_played": "Never",
                                "rating": rateInput,
                                "genre": genreInput,
                                "developer": devInput,
                                "publisher": pubInput,
                                "release_date": dateFormatter.string(from: dateInput),
                            ],
                            icon: iconOutput,
                            name: nameInput,
                            platform: platInput,
                            status: statusInput,
                            is_deleted: false,
                            is_favorite: false
                        )
                        let dispatchGroup = DispatchGroup()
                        
                        for i in games {
                            dispatchGroup.enter()
                            defer {
                                dispatchGroup.leave()
                            }
                            if i.name == newGame.name {
                                showDupeGameToast = true
                            }
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            if !showDupeGameToast {
                                games.append(newGame)
                                games = games.sorted()
                                
                                let encoder = JSONEncoder()
                                encoder.outputFormatting = .prettyPrinted
                                
                                do {
                                    let gamesJSON = try JSONEncoder().encode(games)
                                    
                                    if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                                        // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                                        gamesJSONString = "{\"games\": \(gamesJSONString)}"
                                        writeGamesToJSON(data: gamesJSONString)
                                    }
                                } catch {
                                    logger.write(error.localizedDescription)
                                }
                                if UserDefaults.standard.bool(forKey: "isMetadataFetchingEnabled") {
                                    FetchGameData().getGamesWithName(name: nameInput) { gamesWithName in
                                        fetchedGames = gamesWithName
                                        showChooseGameView.toggle()
                                    }
                                }
//                                showAddedGameToast = true
//                                dismiss()
                            }
                        }
                    },
                    label: {
                        Text("Save Game")
                    }
                )
                .padding()
                .frame(maxWidth: .infinity)

                HStack {
                    Spacer()
                        .frame(maxWidth: .infinity)
                    Spacer()
                        .frame(maxWidth: .infinity)

                    Button (
                        action: {
                            openURL(URL(string: "https://github.com/PhoenixLauncher/Phoenix/blob/main/setup.md")!)
                        }, label: {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color(NSColor.separatorColor), lineWidth: 0.5)
                                    .background(Circle().foregroundColor(Color(NSColor.controlColor)))
                                    .shadow(color: Color(NSColor.separatorColor).opacity(0.3), radius: 1)
                                    .frame(width: 20, height: 20)
                                Text("?").font(.system(size: 15, weight: .regular))
                            }
                        }
                    )
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(minWidth: 768, maxWidth: 1024, maxHeight: 2000)
        .toast(isPresenting: $showDupeGameToast, tapToDismiss: true) {
            AlertToast(type: .error(Color.red), title: "Game already exists with this name!")
        }
        .sheet(isPresented: $showChooseGameView, onDismiss: {
            if let fetchedGame = fetchedGame {
                saveGame(game: fetchedGame)
            }
        }) {
            ChooseGameView(games: $fetchedGames, fetchedGame: $fetchedGame)
        }
    }
    
    func saveGame(game: Game) {
        games.append(game)
        games = games.sorted()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let gamesJSON = try JSONEncoder().encode(games)
            
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
