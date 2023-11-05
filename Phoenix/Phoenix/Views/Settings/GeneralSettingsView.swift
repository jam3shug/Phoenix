//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI
import Defaults

extension Defaults.Keys {
    static let isGameDetectionEnabled = Key<Bool>("isGameDetectionEnabled", default: false)
    static let isMetaDataFetchingEnabled = Key<Bool>("isMetaDataFetchingEnabled", default: true)
}

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 20) {
                Defaults.Toggle("Detect Steam games", key: .isGameDetectionEnabled)
                Defaults.Toggle("Fetch game metadata", key: .isMetaDataFetchingEnabled)
            }
        }
    }
}
