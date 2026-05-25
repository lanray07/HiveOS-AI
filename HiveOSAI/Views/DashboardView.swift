import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Environment(LocalizationService.self) private var localization
    @Environment(StoreKitService.self) private var store
    @Query(sort: \Apiary.createdAt) private var apiaries: [Apiary]
    @Query(sort: \Hive.createdAt) private var hives: [Hive]
    @State private var showingNewInspection = false
    @State private var showingAddHive = false
    @State private var showingSwarmAlertNetwork = false
    @State private var ai = AsyncAIViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                UpgradeBanner()

                SectionPanel(title: localization.t(.healthOverview)) {
                    HivePulseView(status: overallPulse, confidence: averageStrength)
                    HStack {
                        metric("Hives", "\(hives.count)")
                        metric("Watchlist", "\(hives.filter { $0.status == .watchlist || $0.status == .weakColony }.count)")
                        metric("Swarm Risk", "\(hives.filter { $0.status == .swarmRisk }.count)")
                    }
                }

                if let apiary = apiaries.first {
                    ApiaryOverviewCard(apiary: apiary)
                } else {
                    EmptyStateView(title: "No apiary yet", message: "Add an apiary and your first hive to start local tracking.", systemImage: "hexagon")
                }

                SectionPanel(title: localization.t(.quickActions)) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 10)], spacing: 10) {
                        quickAction("New Inspection", "checklist.checked") { showingNewInspection = true }
                        quickAction("Scan Hive", "camera.viewfinder") {}
                        quickAction("Record Hive Audio", "waveform") {}
                        quickAction("View Hive Pulse", "dot.radiowaves.left.and.right") {
                            Task { await runPulse() }
                        }
                        quickAction("Generate Report", "doc.richtext") {}
                        quickAction("Add Hive", "plus.hexagon") { showingAddHive = true }
                        quickAction(localization.t(.swarmAlertNetwork), "antenna.radiowaves.left.and.right") { showingSwarmAlertNetwork = true }
                    }
                }

                WeatherInsightCard()

                SectionPanel(title: localization.t(.subscription)) {
                    HStack {
                        Label(store.activePlan.rawValue, systemImage: "crown.fill")
                        Spacer()
                        Text(store.activePlan == .free ? "Free plan active" : "Active")
                            .foregroundStyle(.secondary)
                    }
                }

                if ai.isLoading {
                    ProgressView("Generating Hive Pulse...")
                } else if let result = ai.result {
                    SectionPanel(title: "Latest Hive Pulse") {
                        HivePulseView(status: result.hivePulse, confidence: result.confidence)
                        Text(result.summary).foregroundStyle(.secondary)
                    }
                }

                ForEach(hives.prefix(3)) { hive in
                    NavigationLink(value: hive.id) { HiveCard(hive: hive) }
                }
            }
            .padding(16)
        }
        .navigationTitle("HiveOS AI")
        .navigationDestination(for: UUID.self) { id in
            if let hive = hives.first(where: { $0.id == id }) {
                HiveDetailView(hive: hive)
            }
        }
        .sheet(isPresented: $showingAddHive) {
            AddHiveView()
        }
        .sheet(isPresented: $showingNewInspection) {
            NewInspectionView()
        }
        .sheet(isPresented: $showingSwarmAlertNetwork) {
            NavigationStack {
                SwarmAlertNetworkView()
            }
        }
        .task { seedIfNeeded() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localization.t(.intelligentBeekeepingOS)).font(.largeTitle.bold())
            Text(localization.t(.dashboardSubtitle))
                .foregroundStyle(.secondary)
        }
    }

    private var averageStrength: Double {
        guard !hives.isEmpty else { return 0.68 }
        return Double(hives.map(\.hiveStrength).reduce(0, +)) / Double(hives.count) / 100
    }

    private var overallPulse: PulseStatus {
        hives.contains { $0.status == .swarmRisk } ? .swarmRiskRising : .productive
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(value).font(.title2.monospacedDigit().bold()).foregroundStyle(.orange)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func quickAction(_ title: String, _ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.callout.bold())
                .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.bordered)
        .tint(.orange)
    }

    private func runPulse() async {
        guard let hive = hives.first else { return }
        await ai.run { try await aiService.generateHivePulse(hive: hive) }
    }

    private func seedIfNeeded() {
        guard apiaries.isEmpty else { return }
        let apiary = Apiary(name: "Golden Ridge Apiary", location: "North Field", climateRegion: "Temperate", notes: "Demo local-first apiary.")
        let hiveA = Hive(hiveName: "Obsidian One", queenAge: "1 year", queenLineage: "Buckfast placeholder", hiveStrength: 86, temperament: "Calm", status: .productive, honeyProductionEstimate: 28, apiary: apiary)
        let hiveB = Hive(hiveName: "Amber Six", queenAge: "2 years", queenLineage: "Local hybrid placeholder", hiveStrength: 63, temperament: "Defensive", status: .watchlist, honeyProductionEstimate: 18, apiary: apiary)
        modelContext.insert(apiary)
        modelContext.insert(hiveA)
        modelContext.insert(hiveB)
    }
}
