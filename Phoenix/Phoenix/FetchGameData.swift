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
        // Create an APICalypse query to specify the search query and fields.
        if name != "" {
            let apicalypse = APICalypse()
                .fields(fields: "id,name,artworks.image_id,artworks.height,category") // Specify the fields you want to retrieve
                .where(query: "name ~ *\"\(name)\"*") // Use the "where" clause to search by name
                .limit(value: 50)

            // Make the API request to search for the game by name.
            wrapper.games(apiCalypse: apicalypse, result: { games in
                // Handle the retrieved games here
                if let lowestIdGame = games.min(by: { $0.id < $1.id }) {
                    // Print the game with the lowest .id
                    print(lowestIdGame.id)
                    for i in 0..<lowestIdGame.artworks.count {
                        print("https://images.igdb.com/igdb/image/upload/t_1080p_2x/\(lowestIdGame.artworks[i].imageID).jpg")
                    }
                }
            }) { error in
                // Handle any errors that occur during the request
                print("Error searching for the game: \(error)")
            }
        }
    }
}
