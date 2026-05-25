import SwiftData
import SwiftUI

@main
struct HiveOSAIApp: App {
    @State private var aiService: any AIService = MockAIService()
    @State private var storeKitService = StoreKitService()
    @State private var notificationService = NotificationService()
    @State private var localizationService = LocalizationService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Apiary.self,
            Hive.self,
            HivePhoto.self,
            Inspection.self,
            HiveAudioRecord.self,
            HivePulse.self,
            HiveReport.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.aiService, aiService)
                .environment(storeKitService)
                .environment(notificationService)
                .environment(localizationService)
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct AIServiceKey: EnvironmentKey {
    static let defaultValue: any AIService = MockAIService()
}

extension EnvironmentValues {
    var aiService: any AIService {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}
