//
//  JournalEntry.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import Foundation
import SwiftData

enum ActivityType: String, Codable, CaseIterable {
    case run = "Run"
    case walk = "Walk"
    case hike = "Hike"
    case bike = "Bike"
    case swim = "Swim"
    case lift = "Lift"
    case reflection = "Reflection"
    case other = "Other"
}

@Model
class JournalEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var title: String
    var text: String
    var stravaLink: String?
    var activityType: ActivityType

    init(id: UUID = UUID(), date: Date, title: String, text: String, stravaLink: String? = nil, activityType: ActivityType = .run) {
        self.id = id
        self.date = date
        self.title = title
        self.text = text
        self.stravaLink = stravaLink
        self.activityType = activityType
    }
}

