import Foundation

protocol AIService: Sendable {
    func analyzeHivePhoto(imageBase64: String?, hiveStatus: HiveStatus, inspectionNotes: String) async throws -> AIHiveResult
    func analyzeHiveAudio(audioPlaceholder: String, hiveStatus: HiveStatus) async throws -> AIHiveResult
    func generateHivePulse(hive: Hive) async throws -> AIHiveResult
    func generateInspectionInsights(inspection: Inspection) async throws -> AIHiveResult
    func generateApiarySummary(apiary: Apiary) async throws -> AIHiveResult
    func generateSwarmRiskEstimate(hive: Hive, weatherData: [String: String]) async throws -> AIHiveResult
}

struct MockAIService: AIService {
    func analyzeHivePhoto(imageBase64: String?, hiveStatus: HiveStatus, inspectionNotes: String) async throws -> AIHiveResult {
        try await Task.sleep(for: .milliseconds(650))
        return AIHiveResult(
            hivePulse: hiveStatus == .swarmRisk ? .swarmRiskRising : .productive,
            confidence: 0.78,
            insights: [
                "Possible sign of brood pattern irregularity in isolated frame zones.",
                "Comb condition may indicate routine maintenance is needed.",
                "Entrance density may indicate elevated colony traffic rather than a confirmed swarm condition."
            ],
            recommendations: [
                "Recommend a hands-on inspection before changing management plans.",
                "Compare current frame photos with prior inspections for trend context.",
                "Verify queen presence and available laying space during the next visit."
            ],
            summary: "Mock AI indicates a generally active colony with possible issues worth independently verifying."
        )
    }

    func analyzeHiveAudio(audioPlaceholder: String, hiveStatus: HiveStatus) async throws -> AIHiveResult {
        try await Task.sleep(for: .milliseconds(500))
        return AIHiveResult(
            hivePulse: .calm,
            confidence: 0.64,
            insights: [
                "Audio placeholder suggests calm activity under mock analysis.",
                "Some elevated frequency bands may indicate increased activity, not a diagnosis."
            ],
            recommendations: [
                "Record a longer sample during consistent weather for better comparison.",
                "Pair audio review with visual inspection notes."
            ],
            summary: "Hive sound appears within a calm placeholder range."
        )
    }

    func generateHivePulse(hive: Hive) async throws -> AIHiveResult {
        try await Task.sleep(for: .milliseconds(450))
        let pulse: PulseStatus
        switch hive.status {
        case .stable: pulse = .calm
        case .productive: pulse = .productive
        case .watchlist: pulse = .resourceStress
        case .swarmRisk: pulse = .swarmRiskRising
        case .queenDistress: pulse = .queenDistressed
        case .weakColony: pulse = .resourceStress
        }
        return AIHiveResult(
            hivePulse: pulse,
            confidence: min(0.92, Double(hive.hiveStrength) / 100.0 + 0.18),
            insights: ["Current pulse is based on mock hive status, inspection history, and strength score."],
            recommendations: ["Use this as an informational planning signal and verify decisions in the apiary."],
            summary: "\(hive.hiveName) is currently reading as \(pulse.rawValue)."
        )
    }

    func generateInspectionInsights(inspection: Inspection) async throws -> AIHiveResult {
        try await Task.sleep(for: .milliseconds(400))
        return AIHiveResult(
            hivePulse: inspection.healthScore > 75 ? .productive : .resourceStress,
            confidence: 0.72,
            insights: ["Inspection notes may indicate \(inspection.inspectionType.rawValue.lowercased()) should be tracked over the next visit cycle."],
            recommendations: ["Keep photos, queen observations, and food store estimates attached to this inspection."],
            summary: "Inspection insight generated with cautious informational language."
        )
    }

    func generateApiarySummary(apiary: Apiary) async throws -> AIHiveResult {
        try await Task.sleep(for: .milliseconds(450))
        return AIHiveResult(
            hivePulse: .productive,
            confidence: 0.75,
            insights: ["Apiary trend appears operationally stable in mock mode."],
            recommendations: ["Review watchlist hives before the next poor-weather window."],
            summary: "\(apiary.name) has \(apiary.hives.count) tracked hives and local-first records."
        )
    }

    func generateSwarmRiskEstimate(hive: Hive, weatherData: [String: String]) async throws -> AIHiveResult {
        try await Task.sleep(for: .milliseconds(500))
        let risk = hive.status == .swarmRisk || hive.hiveStrength > 82
        return AIHiveResult(
            hivePulse: risk ? .swarmRiskRising : .productive,
            confidence: risk ? 0.76 : 0.68,
            insights: [risk ? "Conditions may indicate a rising swarm-risk window." : "Mock swarm risk is not elevated from current local records."],
            recommendations: ["Recommend checking queen cells, brood nest congestion, and available super space."],
            summary: risk ? "Possible swarm pressure should be independently inspected." : "Swarm risk appears moderate to low in mock mode."
        )
    }
}

struct RemoteAIService: AIService {
    private let endpoint = URL(string: "https://YOUR_BACKEND_URL.com/hiveos-ai")!
    private let prompt = "You are HiveOS AI, an agricultural hive intelligence assistant. Review hive images, hive audio placeholders, inspection notes, weather context, and hive history. Generate cautious, informational hive insights using non-definitive language. Do not provide veterinary diagnosis, guaranteed predictions, or regulatory certification. Respond in the requested app language when provided."

    func analyzeHivePhoto(imageBase64: String?, hiveStatus: HiveStatus, inspectionNotes: String) async throws -> AIHiveResult {
        try await post(module: "photo_scan", hiveStatus: hiveStatus.rawValue, inspectionNotes: inspectionNotes, weatherData: [:], imageBase64: imageBase64 ?? "", audioPlaceholder: "")
    }

    func analyzeHiveAudio(audioPlaceholder: String, hiveStatus: HiveStatus) async throws -> AIHiveResult {
        try await post(module: "audio_intelligence", hiveStatus: hiveStatus.rawValue, inspectionNotes: "", weatherData: [:], imageBase64: "", audioPlaceholder: audioPlaceholder)
    }

    func generateHivePulse(hive: Hive) async throws -> AIHiveResult {
        try await post(module: "hive_pulse", hiveStatus: hive.status.rawValue, inspectionNotes: hive.notes, weatherData: [:], imageBase64: "", audioPlaceholder: "")
    }

    func generateInspectionInsights(inspection: Inspection) async throws -> AIHiveResult {
        try await post(module: "inspection", hiveStatus: inspection.hive?.status.rawValue ?? "", inspectionNotes: inspection.notes, weatherData: [:], imageBase64: "", audioPlaceholder: "")
    }

    func generateApiarySummary(apiary: Apiary) async throws -> AIHiveResult {
        try await post(module: "apiary_summary", hiveStatus: "", inspectionNotes: apiary.notes, weatherData: ["climateRegion": apiary.climateRegion], imageBase64: "", audioPlaceholder: "")
    }

    func generateSwarmRiskEstimate(hive: Hive, weatherData: [String: String]) async throws -> AIHiveResult {
        try await post(module: "swarm_risk", hiveStatus: hive.status.rawValue, inspectionNotes: hive.notes, weatherData: weatherData, imageBase64: "", audioPlaceholder: "")
    }

    private func post(module: String, hiveStatus: String, inspectionNotes: String, weatherData: [String: String], imageBase64: String, audioPlaceholder: String) async throws -> AIHiveResult {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let languageCode = UserDefaults.standard.string(forKey: "HiveOSAI.selectedLanguage") ?? Locale.preferredLanguages.first ?? "en"
        request.httpBody = try JSONEncoder().encode(RemoteAIRequest(module: module, hiveStatus: hiveStatus, inspectionNotes: inspectionNotes, weatherData: weatherData, imageBase64: imageBase64, audioPlaceholder: audioPlaceholder, languageCode: languageCode, systemPrompt: prompt))
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(RemoteAIResponse.self, from: data)
        return AIHiveResult(hivePulse: PulseStatus(rawValue: response.hivePulse) ?? .calm, confidence: response.confidence, insights: response.insights, recommendations: response.recommendations, summary: response.summary)
    }
}

private struct RemoteAIRequest: Codable {
    var module: String
    var hiveStatus: String
    var inspectionNotes: String
    var weatherData: [String: String]
    var imageBase64: String
    var audioPlaceholder: String
    var languageCode: String
    var systemPrompt: String
}

private struct RemoteAIResponse: Codable {
    var hivePulse: String
    var confidence: Double
    var insights: [String]
    var recommendations: [String]
    var summary: String
}
