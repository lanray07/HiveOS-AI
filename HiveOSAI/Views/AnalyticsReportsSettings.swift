import Charts
import SwiftData
import SwiftUI
import StoreKit

struct AnalyticsDashboardView: View {
    @Query(sort: \Hive.createdAt) private var hives: [Hive]
    @Query(sort: \Inspection.createdAt) private var inspections: [Inspection]
    @State private var shareURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionPanel(title: "Hive Health Trends") {
                    if hives.isEmpty {
                        Text("Add hives to unlock local analytics.").foregroundStyle(.secondary)
                    } else {
                        HiveAnalyticsChart(hives: hives)
                    }
                }
                SectionPanel(title: "Colony Stability") {
                    HStack {
                        metric("Inspection Frequency", "\(inspections.count)")
                        metric("Stability Score", "\(Int(stabilityScore))")
                        metric("Swarm History", "\(hives.filter { $0.status == .swarmRisk }.count)")
                    }
                    Text("Strongest hive: \(hives.max(by: { $0.hiveStrength < $1.hiveStrength })?.hiveName ?? "Placeholder")")
                    Text("Weakest hive: \(hives.min(by: { $0.hiveStrength < $1.hiveStrength })?.hiveName ?? "Placeholder")")
                }
                SectionPanel(title: "Seasonal Comparison") {
                    Chart(hives) { hive in
                        LineMark(x: .value("Hive", hive.hiveName), y: .value("Honey", hive.honeyProductionEstimate))
                            .foregroundStyle(.yellow)
                        PointMark(x: .value("Hive", hive.hiveName), y: .value("Honey", hive.honeyProductionEstimate))
                            .foregroundStyle(.orange)
                    }
                    .frame(height: 180)
                }
                ReportsView(shareURL: $shareURL)
            }
            .padding(16)
        }
        .navigationTitle("Analytics")
        .sheet(item: $shareURL) { url in ShareSheet(items: [url]) }
    }

    private var stabilityScore: Double {
        guard !hives.isEmpty else { return 0 }
        return Double(hives.map(\.hiveStrength).reduce(0, +)) / Double(hives.count)
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(value).font(.title3.monospacedDigit().bold()).foregroundStyle(.orange)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ReportsView: View {
    @Query(sort: \Hive.createdAt) private var hives: [Hive]
    @Query(sort: \Apiary.createdAt) private var apiaries: [Apiary]
    @Binding var shareURL: URL?
    private let reportTypes = ["Hive Health Summary", "Inspection Logs", "Swarm Risk Report", "Queen Status Summary", "Apiary Overview", "Seasonal Report"]

    var body: some View {
        SectionPanel(title: "Hive Reports") {
            ForEach(reportTypes, id: \.self) { type in
                Button {
                    generate(type)
                } label: {
                    ReportPreviewView(title: type, subtitle: "Native PDF generation and share sheet")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func generate(_ type: String) {
        shareURL = try? PDFReportService.makeReport(hive: hives.first, apiary: apiaries.first, reportType: type)
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreKitService.self) private var store
    @Environment(NotificationService.self) private var notifications
    @Environment(LocalizationService.self) private var localization
    @Query private var apiaries: [Apiary]
    @State private var showPaywall = false
    @State private var resetOnboarding = false

    var body: some View {
        @Bindable var localization = localization
        List {
            Section(localization.t(.language)) {
                Picker(localization.t(.language), selection: $localization.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.nativeName).tag(language)
                    }
                }
                Text(localization.t(.languageSubtitle))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section(localization.t(.subscription)) {
                Button(localization.t(.manageSubscription)) { showPaywall = true }
                Text("\(localization.t(.currentPlan)): \(store.activePlan.rawValue)")
            }
            Section(localization.t(.preferences)) {
                Button("Notification Settings") { Task { await notifications.requestAuthorization() } }
                NavigationLink("Apiary Preferences") { ApiaryManagementView() }
                NavigationLink(localization.t(.swarmAlertNetwork)) { SwarmAlertNetworkView() }
                NavigationLink("Widget Settings") { WidgetsPlaceholderView() }
                NavigationLink("Apple Watch Placeholder Settings") { WatchPlaceholderView() }
            }
            Section("Data") {
                Button("Export Data") {}
                Button("Delete All Data", role: .destructive) {
                    apiaries.forEach { modelContext.delete($0) }
                }
            }
            Section(localization.t(.legal)) {
                NavigationLink("Privacy Policy") { LegalTextView(title: "Privacy Policy", text: "HiveOS AI stores mock app data locally by default. Remote AI requires your own backend endpoint and must not embed API keys in the app.") }
                NavigationLink("Terms of Use") { LegalTextView(title: "Terms of Use", text: "HiveOS AI is provided for agricultural record keeping and informational planning workflows.") }
                NavigationLink(localization.t(.disclaimerTitle)) { LegalTextView(title: localization.t(.disclaimerTitle), text: localization.t(.disclaimerBody)) }
            }
        }
        .navigationTitle(localization.t(.settings))
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .task { await store.loadProducts() }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(StoreKitService.self) private var store
    @Environment(LocalizationService.self) private var localization
    private let privacyURL = URL(string: "https://github.com/lanray07/HiveOS-AI/blob/main/PRIVACY_POLICY.md")!
    private let termsURL = URL(string: "https://github.com/lanray07/HiveOS-AI/blob/main/TERMS_OF_USE.md")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(localization.t(.paywallTitle)).font(.largeTitle.bold())
                    Text(localization.t(.paywallSubtitle)).foregroundStyle(.secondary)
                    plan("Free", price: "£0", features: ["3 hives", "Basic inspections", "Limited AI scans", "7-day analytics"])
                    plan("Premium", price: "£14.99/mo or £119.99/yr", features: ["Unlimited hives", "AI hive scans", "Hive Pulse system", "Advanced analytics", "PDF reports", "Weather intelligence placeholder"])
                    plan("Apiary Pro", price: "£39.99/mo", features: ["Multi-apiary management", "Team collaboration placeholder", "Advanced reports", "Cloud backup placeholder", "Commercial analytics placeholder"])
                    if store.isLoading {
                        ProgressView()
                    } else if store.products.isEmpty {
                        Text("StoreKit 2 scaffolding is ready. Configure products in App Store Connect or the included StoreKit file.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.products) { product in
                            subscriptionProductButton(product)
                        }
                    }
                    Button {
                        Task { await store.restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                    legalLinks
                    if let error = store.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(16)
            }
            .navigationTitle(localization.t(.subscription))
            .toolbar { Button("Done") { dismiss() } }
            .task { await store.loadProducts() }
        }
    }

    private func subscriptionProductButton(_ product: Product) -> some View {
        Button {
            Task { await store.purchase(product) }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(product.displayName)
                    .font(.headline)
                Text(subscriptionDetail(for: product))
                    .font(.subheadline)
                Text("Renews automatically until cancelled. Manage or cancel in your Apple ID subscriptions.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
    }

    private func subscriptionDetail(for product: Product) -> String {
        if let period = product.subscription?.subscriptionPeriod {
            return "\(product.displayPrice) per \(period.unit.localizedName)"
        }
        return product.displayPrice
    }

    private var legalLinks: some View {
        HStack(spacing: 12) {
            Button("Privacy Policy") { openURL(privacyURL) }
            Text("•").foregroundStyle(.secondary)
            Button("Terms of Use") { openURL(termsURL) }
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 4)
    }

    private func plan(_ name: String, price: String, features: [String]) -> some View {
        SectionPanel(title: name) {
            Text(price).font(.title3.bold()).foregroundStyle(.orange)
            ForEach(features, id: \.self) { Label($0, systemImage: "checkmark") }
        }
    }
}

struct LegalTextView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        }
        .navigationTitle(title)
    }
}

private extension Product.SubscriptionPeriod.Unit {
    var localizedName: String {
        switch self {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        case .year: "year"
        @unknown default: "period"
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}
