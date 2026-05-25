import Foundation

@Observable
@MainActor
final class OnboardingViewModel {
    var experience: ExperienceLevel = .hobbyist
    var hiveCount = 3
    var climateRegion = "Temperate"
    var goals: Set<String> = ["Reduce hive loss", "Inspection organization"]
    var wantsNotifications = true
    var didAcceptDisclaimer = false
}

@Observable
@MainActor
final class AsyncAIViewModel {
    var result: AIHiveResult?
    var isLoading = false
    var errorMessage: String?

    func run(_ operation: @escaping () async throws -> AIHiveResult) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            result = try await operation()
        } catch {
            errorMessage = "HiveOS AI could not generate insights right now."
        }
    }
}
