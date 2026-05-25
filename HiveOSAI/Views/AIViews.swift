import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct IntelligenceHubView: View {
    @Query(sort: \Hive.createdAt) private var hives: [Hive]
    @Environment(LocalizationService.self) private var localization

    var body: some View {
        List {
            Section("AI Modules") {
                NavigationLink("AI Hive Scan") { AIHiveScanView(defaultHive: hives.first) }
                NavigationLink("Hive Audio Intelligence") { HiveAudioIntelligenceView(defaultHive: hives.first) }
                NavigationLink("Voice Input Notes") { VoiceInputDemoView() }
                NavigationLink("Hive Pulse System") {
                    if let hive = hives.first { HivePulseSystemView(hive: hive) } else { MissingHiveView() }
                }
                NavigationLink("Weather Intelligence Placeholder") { WeatherIntelligenceView() }
                NavigationLink(localization.t(.swarmAlertNetwork)) { SwarmAlertNetworkView() }
                NavigationLink("Honey Production Placeholder") { HoneyProductionView() }
                NavigationLink("Widgets Placeholder") { WidgetsPlaceholderView() }
                NavigationLink("Apple Watch Placeholder") { WatchPlaceholderView() }
            }
            Section("Disclaimer") {
                Text(localization.t(.disclaimerBody))
            }
        }
        .navigationTitle(localization.t(.intelligence))
        .scrollContentBackground(.hidden)
    }
}

struct AIHiveScanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Query(sort: \Hive.createdAt) private var hives: [Hive]
    var defaultHive: Hive?
    @State private var selectedCategory: HivePhotoCategory = .broodFrame
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showCamera = false
    @State private var notes = ""
    @State private var ai = AsyncAIViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionPanel(title: "Photo Source") {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(HivePhotoCategory.allCases) { Text($0.rawValue).tag($0) }
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label("Upload Hive Photo", systemImage: "photo.on.rectangle")
                        }
                        Button { showCamera = true } label: { Label("Take Hive Photo", systemImage: "camera.fill") }
                        TextField("Inspection notes", text: $notes, axis: .vertical)
                    }

                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Button {
                        Task { await analyze() }
                    } label: {
                        Label("Generate Informational Scan", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                    AIResultPanel(ai: ai)
                }
                .padding(16)
            }
            .navigationTitle("AI Hive Scan")
            .toolbar { Button("Done") { dismiss() } }
            .onChange(of: selectedPhoto) { _, newItem in
                Task { imageData = try? await newItem?.loadTransferable(type: Data.self) }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker { data in imageData = data }
            }
        }
    }

    private func analyze() async {
        let hive = defaultHive ?? hives.first
        if let data = imageData {
            modelContext.insert(HivePhoto(imageData: data, category: selectedCategory, hive: hive))
        }
        let base64 = imageData?.base64EncodedString()
        await ai.run {
            try await aiService.analyzeHivePhoto(imageBase64: base64, hiveStatus: hive?.status ?? .stable, inspectionNotes: notes)
        }
    }
}

struct HiveAudioIntelligenceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Query(sort: \Hive.createdAt) private var hives: [Hive]
    var defaultHive: Hive?
    @State private var recorder = AudioRecorderPlaceholder()
    @State private var ai = AsyncAIViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                SectionPanel(title: "Audio Recording Placeholder") {
                    HivePulseView(status: recorder.isRecording ? .defensive : .calm, confidence: recorder.isRecording ? 0.52 : 0.68)
                    Button {
                        recorder.toggleRecording()
                    } label: {
                        Label(recorder.isRecording ? "Stop Recording" : "Record Hive Sound", systemImage: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    Button { Task { await analyzeAudio() } } label: {
                        Label("Analyze Audio Placeholder", systemImage: "waveform.path.ecg")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                AIResultPanel(ai: ai)
                Spacer()
            }
            .padding(16)
            .navigationTitle("Hive Audio")
            .toolbar { Button("Done") { dismiss() } }
        }
    }

    private func analyzeAudio() async {
        let hive = defaultHive ?? hives.first
        await ai.run {
            try await aiService.analyzeHiveAudio(audioPlaceholder: recorder.currentPlaceholder, hiveStatus: hive?.status ?? .stable)
        }
        if let result = ai.result {
            modelContext.insert(HiveAudioRecord(audioFilePlaceholder: recorder.currentPlaceholder, generatedInsight: result.summary, hive: hive))
        }
    }
}

struct HivePulseSystemView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    let hive: Hive
    @State private var ai = AsyncAIViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionPanel(title: "Live AI Hive Status") {
                    HivePulseView(status: ai.result?.hivePulse ?? .calm, confidence: ai.result?.confidence ?? Double(hive.hiveStrength) / 100)
                    Button {
                        Task { await generate() }
                    } label: {
                        Label("Refresh Hive Pulse", systemImage: "dot.radiowaves.left.and.right")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                AIResultPanel(ai: ai)
            }
            .padding(16)
        }
        .navigationTitle("Hive Pulse")
        .task { if ai.result == nil { await generate() } }
    }

    private func generate() async {
        await ai.run { try await aiService.generateHivePulse(hive: hive) }
        if let result = ai.result {
            modelContext.insert(HivePulse(pulseStatus: result.hivePulse, confidence: result.confidence, hive: hive))
        }
    }
}

struct WeatherIntelligenceView: View {
    @State private var suggestions = [
        "Forage conditions placeholder: moderate availability may support routine inspections.",
        "Feeding reminder placeholder: verify food stores before prolonged rain.",
        "Swarm window alert placeholder: warm, settled periods may merit closer checks."
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                WeatherInsightCard()
                SectionPanel(title: "Weather Alerts") {
                    Label("Temperature changes: placeholder stable", systemImage: "thermometer.medium")
                    Label("Rain and wind: placeholder light disruption", systemImage: "cloud.rain.fill")
                }
                SectionPanel(title: "AI Suggestions") {
                    ForEach(suggestions, id: \.self) { Text($0).foregroundStyle(.secondary) }
                }
            }
            .padding(16)
        }
        .navigationTitle("Weather")
    }
}

struct HoneyProductionView: View {
    @Query(sort: \Hive.createdAt) private var hives: [Hive]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionPanel(title: "Honey Production Placeholder") {
                    ForEach(hives) { hive in
                        HStack {
                            Text(hive.hiveName)
                            Spacer()
                            Text("\(hive.honeyProductionEstimate, specifier: "%.1f") kg")
                                .monospacedDigit()
                                .foregroundStyle(.orange)
                        }
                    }
                    Text("Extraction dates and honey type tracking are ready as placeholder workflow areas.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .navigationTitle("Honey")
    }
}

struct AIResultPanel: View {
    let ai: AsyncAIViewModel
    @Environment(LocalizationService.self) private var localization

    var body: some View {
        Group {
            if ai.isLoading {
                SectionPanel(title: "Generating") {
                    ProgressView("HiveOS AI is reviewing local context...")
                }
            } else if let error = ai.errorMessage {
                SectionPanel(title: "Error") {
                    Label(error, systemImage: "exclamationmark.triangle")
                }
            } else if let result = ai.result {
                SectionPanel(title: localization.t(.informationalInsights)) {
                    HivePulseView(status: result.hivePulse, confidence: result.confidence)
                    Text(result.summary).foregroundStyle(.secondary)
                    Divider()
                    Text(localization.t(.possibleSignals)).font(.headline)
                    ForEach(result.insights, id: \.self) { Label($0, systemImage: "hexagon") }
                    Text(localization.t(.recommendations)).font(.headline)
                    ForEach(result.recommendations, id: \.self) { Label($0, systemImage: "checkmark.seal") }
                    Text(localization.t(.verifyDecisions))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct MissingHiveView: View {
    var body: some View {
        EmptyStateView(title: "No hive selected", message: "Add a hive before generating a pulse.", systemImage: "hexagon")
            .padding(16)
            .navigationTitle("Hive Pulse")
    }
}

struct VoiceInputDemoView: View {
    @State private var notes = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionPanel(title: "Voice Input") {
                    TextField("Dictated hive notes", text: $notes, axis: .vertical)
                    VoiceInputPanel(text: $notes, title: "Record Voice Input")
                    Text("Speech recognition turns field observations into editable text. Verify dictated notes before making hive decisions.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .navigationTitle("Voice Input")
    }
}
