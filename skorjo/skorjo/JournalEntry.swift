//
//  JournalEntry.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import Foundation
import SwiftData

@Model
class JournalEntry: Identifiable {
    var id: UUID
    var date: Date
    var title: String
    var text: String
    var stravaLink: String?
    var activityType: ActivityType

    init(
        date: Date = .now,
        title: String,
        text: String,
        stravaLink: String? = nil,
        activityType: ActivityType = .run
    ) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.text = text
        self.stravaLink = stravaLink
        self.activityType = activityType
    }
}

enum ActivityType: String, Codable, CaseIterable {
    case run = "Run"
    case walk = "Walk"
    case hike = "Hike"
    case lift = "Lift"
    case bike = "Bike"
    case swim = "Swim"
    case other = "Other"
}
