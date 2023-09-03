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
                .search(searchQuery: name) // Specify the search query
                .fields(fields: "id,name") // Specify the fields you want to retrieve (both "id" and "name")

            // Make the API request to search for the game by name.
            wrapper.games(apiCalypse: apicalypse, result: { games in
                // Handle the retrieved games here
                for game in games {
                    if game.name == name {
                        print(game)
                    }
                }
            }) { error in
                // Handle any errors that occur during the request
                print("Error searching for the game: \(error)")
            }
        }
    }
}
