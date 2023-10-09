//
//  FetchGameData.swift
//  Phoenix
//
//  Created by James Hughes on 9/2/23.
//

import Foundation
import SwiftUI
import IGDB_SWIFT_API
import Kingfisher

struct FetchGameData {
    let wrapper: IGDBWrapper = IGDBWrapper(clientID: "aqxuk3zeqtcuquwswjrbohyi2mf5gc", accessToken: "go5xcl37bz41a16plvnudbe6a4fajt")
    
    func fetchGamesFromName(name: String, completion: @escaping ([Proto_Game]) -> Void) {
            // Create an APICalypse query to specify the search query and fields.
            if name != "" {
                let apicalypse = APICalypse()
                    .fields(fields: """
                                    id,
                                    name,
                                    artworks,
                                    cover,
                                    cover.image_id,
                                    artworks.image_id,
                                    artworks.height,
                                    storyline,
                                    summary,
                                    genres.name,
                                    themes.name,
                                    involved_companies.company.name,
                                    involved_companies.publisher,
                                    involved_companies.developer,
                                    first_release_date,
                                    websites.url,
                                    websites.category
                                    """) // Specify the fields you want to retrieve
                    .where(query: "name ~ \"\(name)\"") // Use the "where" clause to search by name
                    .limit(value: 50)
                
                // Make the API request to search for the game by name.
                wrapper.games(apiCalypse: apicalypse, result: { fetchedGames in
                    completion(fetchedGames)
                }) { error in
                    // Handle any errors that occur during the request
                    print("Error searching for the game: \(error)")
                }
            }
    }
    
    func convertIGDBGame(igdbGame: Proto_Game, nameInput: String) {
        guard let idx = games.firstIndex(where: { $0.name == nameInput }) else { return }
        var fetchedGame: Game = .init(
            steamID: games[idx].steamID,
            launcher: games[idx].launcher,
            metadata: [
                "rating": games[idx].metadata["rating"] ?? "",
            ],
            icon: games[idx].icon,
            platform: games[idx].platform,
            status: games[idx].status,
            recency: games[idx].recency,
            is_favorite: games[idx].is_favorite
        )
        
        fetchedGame.name = nameInput
        
        fetchedGame.igdbID = String(igdbGame.id)

        if igdbGame.storyline == "" || igdbGame.storyline.count > 1500 {
            fetchedGame.metadata["description"] = igdbGame.summary
        } else {
            fetchedGame.metadata["description"] = igdbGame.storyline
        }

        // Get the highest resolution artwork
        for website in igdbGame.websites {
            if website.category.rawValue == 13 {
                print("STEAM FOUND")
                // Split the URL string by forward slash and get the last component
                if let lastPathComponent = website.url.split(separator: "/").firstIndex(of: "app").flatMap({ $0 + 1 < website.url.split(separator: "/").count ? website.url.split(separator: "/")[$0 + 1] : nil }) {
                    print("SHOULD WORK")
                    print(website.url)
                    print(lastPathComponent)
                    if let number = Int(lastPathComponent) {
                        fetchedGame.steamID = String(number)
                        getSteamHeader(number: number, name: igdbGame.name) { headerImage in
                            if let headerImage = headerImage {
                                fetchedGame.metadata["header_img"] = headerImage
                                saveFetchedGame(name: fetchedGame.name, fetchedGame: fetchedGame)
                            } else {
                                print("steam is on something")
                            }
                        }
                    } else {
                        logger.write("The last path component is not a valid number.")
                    }
                } else {
                    logger.write("Invalid URL format.")
                }
            } else {
                getIGDBHeader(igdbGame: igdbGame, name: igdbGame.name) { headerImage in
                    if let headerImage = headerImage {
                        fetchedGame.metadata["header_img"] = headerImage
                        saveFetchedGame(name: fetchedGame.name, fetchedGame: fetchedGame)
                    }
                }
            }
        }

        // Combine genres (excluding "Science Fiction")
        var uniqueGenres = Set<String>()
        var combinedCount = 0
        for genre in igdbGame.genres {
            if !genre.name.isEmpty {
                if genre.name.lowercased() == "Science Fiction".lowercased() {
                    uniqueGenres.insert("Sci-fi")
                } else {
                    uniqueGenres.insert(genre.name)
                }
                combinedCount += 1
            }

            if combinedCount >= 3 {
                break
            }
        }
        // Combine themes (excluding "Science Fiction")
        for theme in igdbGame.themes {
            if !theme.name.isEmpty {
                if theme.name.lowercased() == "Science Fiction".lowercased() {
                    uniqueGenres.insert("Sci-fi")
                } else {
                    uniqueGenres.insert(theme.name)
                    combinedCount += 1
                }
            }

            if combinedCount >= 3 {
                break
            }
        }
        // Convert the set to a sorted array
        let combinedGenresString = uniqueGenres.sorted().joined(separator: "\n")
        fetchedGame.metadata["genre"] = combinedGenresString

        var developerSet = Set<String>()
        var publisherSet = Set<String>()

        for company in igdbGame.involvedCompanies {
            let companyName = company.company.name
            
            if company.publisher && publisherSet.count < 2 {
                publisherSet.insert(companyName)
            }
            
            if company.developer && developerSet.count < 2 {
                developerSet.insert(companyName)
            }
        }

        let publishers = publisherSet.joined(separator: "\n")
        let developers = developerSet.joined(separator: "\n")

        if !developers.isEmpty {
            // Set the `developer` variable with newline-separated developers
            fetchedGame.metadata["developer"] = developers
        }
        if !publishers.isEmpty {
            // Set the `publisher` variable with newline-separated publishers
            fetchedGame.metadata["publisher"] = publishers
        }


        // Convert Unix timestamp to Date
        let date = Date(timeIntervalSince1970: TimeInterval(igdbGame.firstReleaseDate.seconds))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"

        fetchedGame.metadata["release_date"] = dateFormatter.string(from: date)

        saveFetchedGame(name: fetchedGame.name, fetchedGame: fetchedGame)
    }
    
    func getSteamHeader(number: Int, name: String, completion: @escaping (String?) -> Void) {
        let imageURL = "https://cdn.cloudflare.steamstatic.com/steam/apps/\(number)/library_hero.jpg"
        if let url = URL(string: imageURL) {	
            URLSession.shared.dataTask(with: url) { headerData, response, error in
                if let headerData = headerData {
                    saveHeaderToFile(headerData: headerData, name: name) { headerImage in
                        completion(headerImage)
                    }
                }
            }.resume()
        }
    }
    
    func getIGDBHeader(igdbGame: Proto_Game, name: String, completion: @escaping (String?) -> Void) {
        if let highestResArtwork = igdbGame.artworks.max(by: { $0.height < $1.height }) {
            let imageURL = imageBuilder(imageID: highestResArtwork.imageID, size: .FHD, imageType: .JPEG)
            if let url = URL(string: imageURL) {
                URLSession.shared.dataTask(with: url) { headerData, response, error in
                    if let headerData = headerData {
                        saveHeaderToFile(headerData: headerData, name: name) { headerImage in
                            completion(headerImage)
                        }
                    }
                }.resume()
            }
        }
    }
    
    func saveFetchedGame(name: String, fetchedGame: Game) {
        if let idx = games.firstIndex(where: { $0.name == name }) {
            games[idx] = fetchedGame
        }
        saveGames()
    }
}
