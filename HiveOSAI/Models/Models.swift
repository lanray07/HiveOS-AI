import Foundation
import SwiftData

enum ExperienceLevel: String, CaseIterable, Identifiable, Codable {
    case beginner = "Beginner"
    case hobbyist = "Hobbyist"
    case advanced = "Advanced"
    case commercial = "Commercial"
    var id: String { rawValue }
}

enum HiveStatus: String, CaseIterable, Identifiable, Codable {
    case stable = "Stable"
    case productive = "Productive"
    case watchlist = "Watchlist"
    case swarmRisk = "Swarm Risk"
    case queenDistress = "Queen Distress"
    case weakColony = "Weak Colony"
    var id: String { rawValue }
}

enum PulseStatus: String, CaseIterable, Identifiable, Codable {
    case calm = "Calm"
    case productive = "Productive"
    case defensive = "Defensive"
    case queenDistressed = "Queen Distressed"
    case swarmRiskRising = "Swarm Risk Rising"
    case resourceStress = "Resource Stress"
    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free = "Free"
    case premium = "Premium"
    case apiaryPro = "Apiary Pro"
    var id: String { rawValue }
}

enum InspectionType: String, CaseIterable, Identifiable, Codable {
    case broodCheck = "Brood Check"
    case queenInspection = "Queen Inspection"
    case pestCheck = "Pest Check"
    case foodStores = "Food Stores"
    case combHealth = "Comb Health"
    case seasonalPrep = "Seasonal Prep"
    case swarmSigns = "Swarm Signs"
    case temperament = "Hive Temperament"
    var id: String { rawValue }
}

enum HivePhotoCategory: String, CaseIterable, Identifiable, Codable {
    case hive = "Hive"
    case broodFrame = "Brood Frame"
    case comb = "Comb"
    case entrance = "Hive Entrance"
    var id: String { rawValue }
}

enum SwarmSightingStatus: String, CaseIterable, Identifiable, Codable {
    case spotted = "Spotted"
    case notified = "Local Beekeepers Notified"
    case claimed = "Claimed"
    case resolved = "Resolved"
    var id: String { rawValue }
}

@Model
final class Apiary {
    var id: UUID
    var name: String
    var location: String
    var climateRegion: String
    var notes: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Hive.apiary)
    var hives: [Hive] = []

    init(id: UUID = UUID(), name: String, location: String, climateRegion: String, notes: String = "", createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.location = location
        self.climateRegion = climateRegion
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
final class Hive {
    var id: UUID
    var hiveName: String
    var queenAge: String
    var queenLineage: String
    var hiveStrength: Int
    var temperament: String
    var statusRawValue: String
    var notes: String
    var honeyProductionEstimate: Double
    var createdAt: Date
    var apiary: Apiary?

    @Relationship(deleteRule: .cascade, inverse: \Inspection.hive)
    var inspections: [Inspection] = []
    @Relationship(deleteRule: .cascade, inverse: \HivePhoto.hive)
    var photos: [HivePhoto] = []
    @Relationship(deleteRule: .cascade, inverse: \HivePulse.hive)
    var pulses: [HivePulse] = []

    var status: HiveStatus {
        get { HiveStatus(rawValue: statusRawValue) ?? .stable }
        set { statusRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), hiveName: String, queenAge: String = "Unknown", queenLineage: String = "Placeholder", hiveStrength: Int = 72, temperament: String = "Calm", status: HiveStatus = .stable, notes: String = "", honeyProductionEstimate: Double = 0, createdAt: Date = .now, apiary: Apiary? = nil) {
        self.id = id
        self.hiveName = hiveName
        self.queenAge = queenAge
        self.queenLineage = queenLineage
        self.hiveStrength = hiveStrength
        self.temperament = temperament
        self.statusRawValue = status.rawValue
        self.notes = notes
        self.honeyProductionEstimate = honeyProductionEstimate
        self.createdAt = createdAt
        self.apiary = apiary
    }
}

@Model
final class HivePhoto {
    var id: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var localImageURL: URL?
    var categoryRawValue: String
    var createdAt: Date
    var hive: Hive?

    var category: HivePhotoCategory {
        get { HivePhotoCategory(rawValue: categoryRawValue) ?? .hive }
        set { categoryRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), imageData: Data? = nil, localImageURL: URL? = nil, category: HivePhotoCategory, createdAt: Date = .now, hive: Hive? = nil) {
        self.id = id
        self.imageData = imageData
        self.localImageURL = localImageURL
        self.categoryRawValue = category.rawValue
        self.createdAt = createdAt
        self.hive = hive
    }
}

@Model
final class Inspection {
    var id: UUID
    var inspectionTypeRawValue: String
    var notes: String
    var healthScore: Int
    var checklist: [String]
    var createdAt: Date
    var hive: Hive?

    var inspectionType: InspectionType {
        get { InspectionType(rawValue: inspectionTypeRawValue) ?? .broodCheck }
        set { inspectionTypeRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), inspectionType: InspectionType, notes: String, healthScore: Int, checklist: [String] = [], createdAt: Date = .now, hive: Hive? = nil) {
        self.id = id
        self.inspectionTypeRawValue = inspectionType.rawValue
        self.notes = notes
        self.healthScore = healthScore
        self.checklist = checklist
        self.createdAt = createdAt
        self.hive = hive
    }
}

@Model
final class HiveAudioRecord {
    var id: UUID
    var audioFilePlaceholder: String
    var generatedInsight: String
    var createdAt: Date
    var hive: Hive?

    init(id: UUID = UUID(), audioFilePlaceholder: String = "local-audio-placeholder.m4a", generatedInsight: String, createdAt: Date = .now, hive: Hive? = nil) {
        self.id = id
        self.audioFilePlaceholder = audioFilePlaceholder
        self.generatedInsight = generatedInsight
        self.createdAt = createdAt
        self.hive = hive
    }
}

@Model
final class HivePulse {
    var id: UUID
    var pulseStatusRawValue: String
    var confidence: Double
    var createdAt: Date
    var hive: Hive?

    var pulseStatus: PulseStatus {
        get { PulseStatus(rawValue: pulseStatusRawValue) ?? .calm }
        set { pulseStatusRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), pulseStatus: PulseStatus, confidence: Double, createdAt: Date = .now, hive: Hive? = nil) {
        self.id = id
        self.pulseStatusRawValue = pulseStatus.rawValue
        self.confidence = confidence
        self.createdAt = createdAt
        self.hive = hive
    }
}

@Model
final class HiveReport {
    var id: UUID
    var reportType: String
    var pdfLocalURL: URL?
    var createdAt: Date
    var hive: Hive?

    init(id: UUID = UUID(), reportType: String, pdfLocalURL: URL? = nil, createdAt: Date = .now, hive: Hive? = nil) {
        self.id = id
        self.reportType = reportType
        self.pdfLocalURL = pdfLocalURL
        self.createdAt = createdAt
        self.hive = hive
    }
}

@Model
final class SubscriptionState {
    var id: UUID
    var planRawValue: String
    var isActive: Bool
    var renewsAt: Date?

    var plan: SubscriptionPlan {
        get { SubscriptionPlan(rawValue: planRawValue) ?? .free }
        set { planRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), plan: SubscriptionPlan = .free, isActive: Bool = false, renewsAt: Date? = nil) {
        self.id = id
        self.planRawValue = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}

@Model
final class SwarmSighting {
    var id: UUID
    var title: String
    var locationDescription: String
    var latitude: Double?
    var longitude: Double?
    var estimatedClusterSize: String
    var heightDescription: String
    var contactName: String
    var contactMethod: String
    var notes: String
    var statusRawValue: String
    var notifyLocalBeekeepers: Bool
    var createdAt: Date

    var status: SwarmSightingStatus {
        get { SwarmSightingStatus(rawValue: statusRawValue) ?? .spotted }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        locationDescription: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        estimatedClusterSize: String,
        heightDescription: String,
        contactName: String,
        contactMethod: String,
        notes: String = "",
        status: SwarmSightingStatus = .spotted,
        notifyLocalBeekeepers: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.locationDescription = locationDescription
        self.latitude = latitude
        self.longitude = longitude
        self.estimatedClusterSize = estimatedClusterSize
        self.heightDescription = heightDescription
        self.contactName = contactName
        self.contactMethod = contactMethod
        self.notes = notes
        self.statusRawValue = status.rawValue
        self.notifyLocalBeekeepers = notifyLocalBeekeepers
        self.createdAt = createdAt
    }
}

struct AIHiveResult: Codable, Hashable {
    var hivePulse: PulseStatus
    var confidence: Double
    var insights: [String]
    var recommendations: [String]
    var summary: String
}
