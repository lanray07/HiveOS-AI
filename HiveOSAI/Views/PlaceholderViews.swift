import SwiftUI

struct WidgetsPlaceholderView: View {
    private let widgets = ["Hive Pulse", "Today's Hive Alerts", "Swarm Risk", "Inspection Reminder"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionPanel(title: "WidgetKit Placeholder") {
                    ForEach(widgets, id: \.self) { widget in
                        Label(widget, systemImage: "rectangle.inset.filled")
                    }
                    Text("Widget extension architecture placeholder. Add a WidgetKit target when shipping companion widgets.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .navigationTitle("Widgets")
    }
}

struct WatchPlaceholderView: View {
    private let features = ["Hive alerts", "Inspection reminders", "Quick pulse view", "Apiary notifications"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionPanel(title: "Apple Watch Placeholder") {
                    ForEach(features, id: \.self) { feature in
                        Label(feature, systemImage: "applewatch")
                    }
                    Text("Watch app architecture placeholder. Add a watchOS target when implementing wearable alerts and glanceable pulse views.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .navigationTitle("Apple Watch")
    }
}
