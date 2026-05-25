import SwiftData
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case apiaries = "Apiaries"
    case intelligence = "AI"
    case analytics = "Analytics"
    case settings = "Settings"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .apiaries: return "hexagon.fill"
        case .intelligence: return "sparkles"
        case .analytics: return "chart.xyaxis.line"
        case .settings: return "gearshape.fill"
        }
    }

    var localizedKey: L10nKey {
        switch self {
        case .dashboard: return .dashboard
        case .apiaries: return .apiaries
        case .intelligence: return .intelligence
        case .analytics: return .analytics
        case .settings: return .settings
        }
    }
}

struct ContentView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    var body: some View {
        ZStack {
            LuxuryBackground()
            if didCompleteOnboarding {
                AppShell()
            } else {
                OnboardingView(didCompleteOnboarding: $didCompleteOnboarding)
            }
        }
    }
}

struct AppShell: View {
    @State private var selectedTab: AppTab = .dashboard
    @Environment(LocalizationService.self) private var localization

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    Group {
                        switch tab {
                        case .dashboard: DashboardView()
                        case .apiaries: ApiaryManagementView()
                        case .intelligence: IntelligenceHubView()
                        case .analytics: AnalyticsDashboardView()
                        case .settings: SettingsView()
                        }
                    }
                    .toolbarBackground(.black.opacity(0.7), for: .navigationBar)
                }
                .tabItem { Label(localization.t(tab.localizedKey), systemImage: tab.symbol) }
                .tag(tab)
            }
        }
        .tint(.orange)
    }
}

struct OnboardingView: View {
    @Binding var didCompleteOnboarding: Bool
    @State private var viewModel = OnboardingViewModel()
    @Environment(NotificationService.self) private var notifications
    @Environment(LocalizationService.self) private var localization
    private let goals = ["Reduce hive loss", "Improve honey yield", "Queen tracking", "Swarm prevention", "Inspection organization"]
    private let regions = ["Temperate", "Mediterranean", "Continental", "Coastal", "Subtropical", "Arid"]

    var body: some View {
        @Bindable var localization = localization
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.t(.appName)).font(.largeTitle.bold())
                        Text(localization.t(.operatingSystem)).font(.title3).foregroundStyle(.orange)
                        Text(localization.t(.hiveSpeaks)).foregroundStyle(.secondary)
                    }

                    SectionPanel(title: localization.t(.language)) {
                        Picker(localization.t(.language), selection: $localization.language) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.nativeName).tag(language)
                            }
                        }
                        Text(localization.t(.languageSubtitle))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    SectionPanel(title: localization.t(.experience)) {
                        Picker("Experience", selection: $viewModel.experience) {
                            ForEach(ExperienceLevel.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    SectionPanel(title: localization.t(.operation)) {
                        Stepper("Number of hives: \(viewModel.hiveCount)", value: $viewModel.hiveCount, in: 1...500)
                        Picker("Climate region", selection: $viewModel.climateRegion) {
                            ForEach(regions, id: \.self) { Text($0).tag($0) }
                        }
                    }

                    SectionPanel(title: localization.t(.primaryGoals)) {
                        ForEach(goals, id: \.self) { goal in
                            Toggle(goal, isOn: Binding(get: { viewModel.goals.contains(goal) }, set: { enabled in
                                if enabled { viewModel.goals.insert(goal) } else { viewModel.goals.remove(goal) }
                            }))
                        }
                    }

                    SectionPanel(title: localization.t(.notifications)) {
                        Toggle("Inspection reminders and hive alerts", isOn: $viewModel.wantsNotifications)
                    }

                    SectionPanel(title: localization.t(.disclaimerTitle)) {
                        Text(localization.t(.disclaimerBody))
                            .foregroundStyle(.secondary)
                        Toggle(localization.t(.acceptDisclaimer), isOn: $viewModel.didAcceptDisclaimer)
                    }

                    Button {
                        Task {
                            if viewModel.wantsNotifications {
                                await notifications.requestAuthorization()
                            }
                            didCompleteOnboarding = true
                        }
                    } label: {
                        Label(localization.t(.enterApp), systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(!viewModel.didAcceptDisclaimer)
                }
                .padding(20)
            }
            .navigationTitle(localization.t(.onboarding))
        }
    }
}
