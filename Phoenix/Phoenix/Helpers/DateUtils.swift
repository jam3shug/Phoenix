//
//  DateUtils.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import Foundation

func convertIntoLong(input: Date) -> String {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    return dateFormatter.string(from: input)
}
