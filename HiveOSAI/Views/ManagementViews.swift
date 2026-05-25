import PhotosUI
import SwiftData
import SwiftUI

struct ApiaryManagementView: View {
    @Query(sort: \Apiary.createdAt) private var apiaries: [Apiary]
    @State private var showingAddApiary = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if apiaries.isEmpty {
                    EmptyStateView(title: "No apiaries", message: "Create your first apiary to manage locations, climate regions, hives, and notes.", systemImage: "mappin.and.ellipse")
                }
                ForEach(apiaries) { apiary in
                    NavigationLink(value: apiary.id) {
                        ApiaryOverviewCard(apiary: apiary)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Apiaries")
        .toolbar {
            Button { showingAddApiary = true } label: { Image(systemName: "plus") }
        }
        .navigationDestination(for: UUID.self) { id in
            if let apiary = apiaries.first(where: { $0.id == id }) {
                ApiaryDetailView(apiary: apiary)
            }
        }
        .sheet(isPresented: $showingAddApiary) { AddApiaryView() }
    }
}

struct ApiaryDetailView: View {
    @Bindable var apiary: Apiary
    @State private var showingAddHive = false

    var body: some View {
        Form {
            Section("Apiary") {
                TextField("Name", text: $apiary.name)
                TextField("Location", text: $apiary.location)
                TextField("Climate region", text: $apiary.climateRegion)
                TextField("Notes", text: $apiary.notes, axis: .vertical)
            }
            Section("Honey Production Placeholder") {
                Text("Seasonal estimates are aggregated from hive profiles and report records.")
            }
            Section("Hives") {
                ForEach(apiary.hives) { hive in
                    NavigationLink(hive.hiveName, value: hive.id)
                }
            }
        }
        .navigationTitle(apiary.name)
        .toolbar {
            Button { showingAddHive = true } label: { Image(systemName: "plus.hexagon") }
        }
        .navigationDestination(for: UUID.self) { id in
            if let hive = apiary.hives.first(where: { $0.id == id }) {
                HiveDetailView(hive: hive)
            }
        }
        .sheet(isPresented: $showingAddHive) { AddHiveView(defaultApiary: apiary) }
    }
}

struct HiveDetailView: View {
    @Bindable var hive: Hive
    @State private var showingInspection = false
    @State private var showingScan = false
    @State private var showingAudio = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HiveCard(hive: hive)
                SectionPanel(title: "Hive Profile") {
                    TextField("Hive name", text: $hive.hiveName)
                    TextField("Queen age", text: $hive.queenAge)
                    TextField("Queen lineage placeholder", text: $hive.queenLineage)
                    Stepper("Hive strength: \(hive.hiveStrength)%", value: $hive.hiveStrength, in: 0...100)
                    TextField("Temperament", text: $hive.temperament)
                    Picker("Status", selection: Binding(get: { hive.status }, set: { hive.status = $0 })) {
                        ForEach(HiveStatus.allCases) { Text($0.rawValue).tag($0) }
                    }
                    TextField("Honey production estimate", value: $hive.honeyProductionEstimate, format: .number)
                    TextField("Notes", text: $hive.notes, axis: .vertical)
                }

                SectionPanel(title: "Inspection History") {
                    if hive.inspections.isEmpty {
                        Text("No inspections recorded yet.").foregroundStyle(.secondary)
                    } else {
                        ForEach(hive.inspections.sorted(by: { $0.createdAt > $1.createdAt })) { InspectionCard(inspection: $0) }
                    }
                }

                SectionPanel(title: "Photos") {
                    Text("\(hive.photos.count) local photos attached").foregroundStyle(.secondary)
                    Button("Open AI Hive Scan") { showingScan = true }
                }

                SectionPanel(title: "Actions") {
                    Button("New Inspection") { showingInspection = true }
                    Button("Hive Audio Intelligence") { showingAudio = true }
                    NavigationLink("Hive Pulse System") { HivePulseSystemView(hive: hive) }
                }
            }
            .padding(16)
        }
        .navigationTitle(hive.hiveName)
        .sheet(isPresented: $showingInspection) { NewInspectionView(defaultHive: hive) }
        .sheet(isPresented: $showingScan) { AIHiveScanView(defaultHive: hive) }
        .sheet(isPresented: $showingAudio) { HiveAudioIntelligenceView(defaultHive: hive) }
    }
}

struct AddApiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var location = ""
    @State private var climateRegion = "Temperate"
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Apiary name", text: $name)
                TextField("Location", text: $location)
                TextField("Climate region", text: $climateRegion)
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .navigationTitle("Add Apiary")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        modelContext.insert(Apiary(name: name.isEmpty ? "New Apiary" : name, location: location, climateRegion: climateRegion, notes: notes))
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddHiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Apiary.createdAt) private var apiaries: [Apiary]
    var defaultApiary: Apiary?
    @State private var hiveName = ""
    @State private var queenAge = "Unknown"
    @State private var strength = 70
    @State private var temperament = "Calm"
    @State private var status: HiveStatus = .stable

    var body: some View {
        NavigationStack {
            Form {
                TextField("Hive name", text: $hiveName)
                TextField("Queen age", text: $queenAge)
                Stepper("Hive strength: \(strength)%", value: $strength, in: 0...100)
                TextField("Temperament", text: $temperament)
                Picker("Status", selection: $status) {
                    ForEach(HiveStatus.allCases) { Text($0.rawValue).tag($0) }
                }
            }
            .navigationTitle("Add Hive")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let hive = Hive(hiveName: hiveName.isEmpty ? "New Hive" : hiveName, queenAge: queenAge, hiveStrength: strength, temperament: temperament, status: status, apiary: defaultApiary ?? apiaries.first)
                        modelContext.insert(hive)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NewInspectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Hive.createdAt) private var hives: [Hive]
    var defaultHive: Hive?
    @State private var selectedType: InspectionType = .broodCheck
    @State private var notes = ""
    @State private var healthScore = 74
    @State private var checklist: Set<String> = []
    private let items = ["Brood visible", "Queen observed", "Food stores checked", "Pest signs reviewed", "Comb condition checked", "Swarm signs reviewed"]

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $selectedType) {
                    ForEach(InspectionType.allCases) { Text($0.rawValue).tag($0) }
                }
                Stepper("Health score: \(healthScore)", value: $healthScore, in: 0...100)
                Section("Checklist") {
                    ForEach(items, id: \.self) { item in
                        Toggle(item, isOn: Binding(get: { checklist.contains(item) }, set: { enabled in
                            if enabled { checklist.insert(item) } else { checklist.remove(item) }
                        }))
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
                Text("Voice notes placeholder available in audio module. Photos can be added through AI Hive Scan.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("New Inspection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let inspection = Inspection(inspectionType: selectedType, notes: notes, healthScore: healthScore, checklist: Array(checklist), hive: defaultHive ?? hives.first)
                        modelContext.insert(inspection)
                        dismiss()
                    }
                }
            }
        }
    }
}
