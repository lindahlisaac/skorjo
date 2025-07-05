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
    case weeklyRecap = "Weekly Recap"
    case injury = "Injury"
}

enum InjurySide: String, Codable, CaseIterable {
    case left = "Left"
    case right = "Right"
    case na = "N/A"
}

struct InjuryCheckIn: Codable, Hashable {
    var date: Date
    var pain: Int
    var notes: String?
}

@Model
class JournalEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var title: String
    var text: String
    var stravaLink: String?
    var activityType: ActivityType
    var feeling: Int? // 1-10, optional for backward compatibility
    var endDate: Date? // For weekly recap
    var weekFeeling: Int? // For weekly recap
    var injuryName: String?
    var injuryStartDate: Date?
    var injuryCheckIns: [InjuryCheckIn]?
    var injuryDetails: String?
    var injurySide: InjurySide?

    init(id: UUID = UUID(), date: Date, title: String, text: String, stravaLink: String? = nil, activityType: ActivityType = .run, feeling: Int? = nil, endDate: Date? = nil, weekFeeling: Int? = nil, injuryName: String? = nil, injuryStartDate: Date? = nil, injuryCheckIns: [InjuryCheckIn]? = nil, injuryDetails: String? = nil, injurySide: InjurySide? = nil) {
        self.id = id
        self.date = date
        self.title = title
        self.text = text
        self.stravaLink = stravaLink
        self.activityType = activityType
        self.feeling = feeling
        self.endDate = endDate
        self.weekFeeling = weekFeeling
        self.injuryName = injuryName
        self.injuryStartDate = injuryStartDate
        self.injuryCheckIns = injuryCheckIns
        self.injuryDetails = injuryDetails
        self.injurySide = injurySide
    }
}

