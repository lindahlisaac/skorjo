//
//  JournalEntry.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import Foundation
import SwiftData

@Model
class JournalEntry {
    var date: Date
    var text: String

    init(date: Date = .now, text: String) {
        self.date = date
        self.text = text
    }
}
