//
//  FetchGameData.swift
//  Phoenix
//
//  Created by James Hughes on 9/2/23.
//

import Foundation
import IGDB_SWIFT_API

struct FetchGameData {
    let wrapper: IGDBWrapper = IGDBWrapper(clientID: "aqxuk3zeqtcuquwswjrbohyi2mf5gc", accessToken: "go5xcl37bz41a16plvnudbe6a4fajt")

    func searchGameByName(name: String) {
        if let idx = games.firstIndex(where: { $0.name == name }) {
            let game = games[idx]
            
            var fetchedGame: Game = .init(
                launcher: game.launcher,
                metadata: [
                    "description": game.metadata["description"] ?? "",
                    "header_img": game.metadata["header_img"] ?? "",
                    "rating": game.metadata["rating"] ?? "",
                    "genre": game.metadata["genre"] ?? "",
                    "developer": game.metadata["developer"] ?? "",
                    "publisher": game.metadata["publisher"] ?? "",
                    "release_date": game.metadata["release_date"] ?? "",
                ],
                icon: game.icon,
                name: game.name,
                platform: game.platform,
                status: game.status,
                is_deleted: game.is_deleted,
                is_favorite: game.is_favorite
            )
        }
        // Create an APICalypse query to specify the search query and fields.
        if name != "" {
            let apicalypse = APICalypse()
                .fields(fields: "id,name,artworks.image_id,artworks.height,description") // Specify the fields you want to retrieve
                .where(query: "name ~ *\"\(name)\"*") // Use the "where" clause to search by name
                .limit(value: 50)

            // Make the API request to search for the game by name.
            wrapper.games(apiCalypse: apicalypse, result: { games in
                // Handle the retrieved games here
                if let lowestIdGame = games.min(by: { $0.id < $1.id }) {
                    
                }
            }) { error in
                // Handle any errors that occur during the request
                print("Error searching for the game: \(error)")
            }
        }
    }
}
