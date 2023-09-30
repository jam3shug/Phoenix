//
//  InfoCard.swift
//  Phoenix
//
//  Created by James Hughes on 9/29/23.
//

import SwiftUI

struct TextCard: View {
    
    var text: String
    var backupText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text ?? backupText)
                .font(.system(size: 14.5))
                .lineSpacing(3.5)
                .padding(10)
        }
        .background(Color.gray.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 7.5)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(7.5)
    }
}

