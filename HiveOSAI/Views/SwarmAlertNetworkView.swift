import SwiftData
import SwiftUI

struct SwarmAlertNetworkView: View {
    @Environment(LocalizationService.self) private var localization
    @Query(sort: \SwarmSighting.createdAt, order: .reverse) private var sightings: [SwarmSighting]
    @State private var showingReportForm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionPanel(title: localization.t(.swarmAlertNetwork)) {
                    Text(localization.t(.swarmAlertSubtitle))
                        .foregroundStyle(.secondary)
                    Text("Community alert placeholder: this release stores sightings locally and schedules local notifications. A production network should use verified opt-in contacts, location privacy controls, abuse prevention, and a secure backend.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        showingReportForm = true
                    } label: {
                        Label("Report Swarm Sighting", systemImage: "megaphone.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }

                SectionPanel(title: "Active Local Alerts") {
                    if sightings.isEmpty {
                        EmptyStateView(title: "No swarm sightings", message: "Report a swarm to notify nearby beekeepers and keep a local response log.", systemImage: "antenna.radiowaves.left.and.right")
                    } else {
                        ForEach(sightings) { sighting in
                            SwarmSightingCard(sighting: sighting)
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(localization.t(.swarmAlertNetwork))
        .toolbar {
            Button { showingReportForm = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showingReportForm) {
            ReportSwarmSightingView()
        }
    }
}

struct SwarmSightingCard: View {
    @Bindable var sighting: SwarmSighting

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sighting.title).font(.headline)
                    Text(sighting.locationDescription).foregroundStyle(.secondary)
                }
                Spacer()
                Text(sighting.status.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.18), in: Capsule())
                    .foregroundStyle(statusColor)
            }

            HStack {
                Label(sighting.estimatedClusterSize, systemImage: "circle.hexagongrid.fill")
                Spacer()
                Label(sighting.heightDescription, systemImage: "arrow.up.and.down")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !sighting.contactMethod.isEmpty {
                Label("Contact: \(sighting.contactMethod)", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !sighting.notes.isEmpty {
                Text(sighting.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Picker("Status", selection: Binding(get: { sighting.status }, set: { sighting.status = $0 })) {
                ForEach(SwarmSightingStatus.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }

    private var statusColor: Color {
        switch sighting.status {
        case .spotted: return .orange
        case .notified: return .yellow
        case .claimed: return .blue
        case .resolved: return .green
        }
    }
}

struct ReportSwarmSightingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notifications
    @State private var title = "Swarm spotted"
    @State private var locationDescription = ""
    @State private var estimatedClusterSize = "Football-sized"
    @State private var heightDescription = "Reachable from ground"
    @State private var contactName = ""
    @State private var contactMethod = ""
    @State private var notes = ""
    @State private var notifyLocalBeekeepers = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Sighting") {
                    TextField("Title", text: $title)
                    TextField("Location description", text: $locationDescription, axis: .vertical)
                    Picker("Estimated cluster size", selection: $estimatedClusterSize) {
                        Text("Small cluster").tag("Small cluster")
                        Text("Football-sized").tag("Football-sized")
                        Text("Large branch cluster").tag("Large branch cluster")
                        Text("Unknown").tag("Unknown")
                    }
                    TextField("Height/access notes", text: $heightDescription)
                    TextField("Notes", text: $notes, axis: .vertical)
                    VoiceInputPanel(text: $notes, title: "Voice Swarm Notes")
                }

                Section("Contact") {
                    TextField("Contact name", text: $contactName)
                    TextField("Phone, email, or preferred contact", text: $contactMethod)
                    Toggle("Notify local beekeepers", isOn: $notifyLocalBeekeepers)
                }

                Section("Safety") {
                    Text("Only share sightings you are permitted to share. Do not trespass, disturb a swarm, or imply guaranteed collection. Local response requires verified contacts and independent beekeeper judgement.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Report Swarm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send Alert") {
                        save()
                    }
                    .disabled(locationDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let sighting = SwarmSighting(
            title: title.isEmpty ? "Swarm spotted" : title,
            locationDescription: locationDescription,
            estimatedClusterSize: estimatedClusterSize,
            heightDescription: heightDescription,
            contactName: contactName,
            contactMethod: contactMethod,
            notes: notes,
            status: notifyLocalBeekeepers ? .notified : .spotted,
            notifyLocalBeekeepers: notifyLocalBeekeepers
        )
        modelContext.insert(sighting)
        if notifyLocalBeekeepers {
            Task {
                await notifications.requestAuthorization()
                notifications.scheduleSwarmAlert(for: sighting)
            }
        }
        dismiss()
    }
}
