import Charts
import SwiftUI

struct LuxuryBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.018, blue: 0.015)
            LinearGradient(colors: [.black.opacity(0.2), .orange.opacity(0.18), .black.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
            HexPattern().stroke(.orange.opacity(0.08), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

struct HexPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width: CGFloat = 54
        let height = width * 0.866
        var y: CGFloat = -height
        var row = 0
        while y < rect.height + height {
            var x: CGFloat = row.isMultiple(of: 2) ? -width : -width / 2
            while x < rect.width + width {
                let center = CGPoint(x: x + width / 2, y: y + height / 2)
                let points = (0..<6).map { index in
                    let angle = CGFloat(index) * .pi / 3 + .pi / 6
                    return CGPoint(x: center.x + cos(angle) * width / 2, y: center.y + sin(angle) * width / 2)
                }
                path.move(to: points[0])
                points.dropFirst().forEach { path.addLine(to: $0) }
                path.closeSubpath()
                x += width
            }
            row += 1
            y += height
        }
        return path
    }
}

struct SectionPanel<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.headline)
            content
        }
        .padding(16)
        .background(.black.opacity(0.44), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.orange.opacity(0.28), lineWidth: 1))
    }
}

struct HiveCard: View {
    let hive: Hive

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(hive.hiveName).font(.title3.bold())
                    Text(hive.apiary?.name ?? "Unassigned apiary").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                SwarmRiskBadge(status: hive.status)
            }
            HivePulseView(status: pulseStatus, confidence: Double(hive.hiveStrength) / 100)
            HStack {
                Label("\(hive.hiveStrength)% strength", systemImage: "waveform.path.ecg")
                Spacer()
                Label(hive.temperament, systemImage: "sparkles")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.orange.opacity(0.22)))
    }

    private var pulseStatus: PulseStatus {
        switch hive.status {
        case .stable: return .calm
        case .productive: return .productive
        case .watchlist: return .resourceStress
        case .swarmRisk: return .swarmRiskRising
        case .queenDistress: return .queenDistressed
        case .weakColony: return .resourceStress
        }
    }
}

struct HivePulseView: View {
    let status: PulseStatus
    let confidence: Double
    @State private var glow = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(status.rawValue).font(.headline)
                Spacer()
                Text("\(Int(confidence * 100))%").monospacedDigit().foregroundStyle(.orange)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.08))
                    Capsule()
                        .fill(LinearGradient(colors: [.yellow, .orange, pulseColor], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(16, proxy.size.width * confidence))
                        .shadow(color: pulseColor.opacity(glow ? 0.8 : 0.25), radius: glow ? 14 : 6)
                }
            }
            .frame(height: 12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                glow.toggle()
            }
        }
    }

    private var pulseColor: Color {
        switch status {
        case .calm, .productive: .green
        case .defensive, .resourceStress: .orange
        case .queenDistressed, .swarmRiskRising: .red
        }
    }
}

struct SwarmRiskBadge: View {
    let status: HiveStatus

    var body: some View {
        Label(status.rawValue, systemImage: status == .swarmRisk ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.18), in: Capsule())
            .foregroundStyle(color)
    }

    private var color: Color {
        switch status {
        case .stable, .productive: .green
        case .watchlist, .weakColony: .orange
        case .swarmRisk, .queenDistress: .red
        }
    }
}

struct ApiaryOverviewCard: View {
    let apiary: Apiary

    var body: some View {
        SectionPanel(title: apiary.name) {
            Text(apiary.location).foregroundStyle(.secondary)
            HStack {
                Label("\(apiary.hives.count) hives", systemImage: "hexagon.fill")
                Spacer()
                Label(apiary.climateRegion, systemImage: "cloud.sun.fill")
            }
            .font(.subheadline)
        }
    }
}

struct InspectionCard: View {
    let inspection: Inspection

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checklist.checked").foregroundStyle(.orange)
            VStack(alignment: .leading) {
                Text(inspection.inspectionType.rawValue).font(.headline)
                Text(inspection.notes.isEmpty ? "No notes added" : inspection.notes).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer()
            Text("\(inspection.healthScore)").font(.title3.monospacedDigit()).foregroundStyle(.orange)
        }
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct HiveAnalyticsChart: View {
    let hives: [Hive]

    var body: some View {
        Chart(hives) { hive in
            BarMark(x: .value("Hive", hive.hiveName), y: .value("Strength", hive.hiveStrength))
                .foregroundStyle(.orange.gradient)
            RuleMark(y: .value("Stable", 70)).foregroundStyle(.green.opacity(0.55))
        }
        .chartYScale(domain: 0...100)
        .frame(height: 220)
    }
}

struct WeatherInsightCard: View {
    @Environment(LocalizationService.self) private var localization

    var body: some View {
        SectionPanel(title: localization.t(.weatherIntelligence)) {
            Label("Forage conditions: placeholder favorable", systemImage: "leaf.fill")
            Label("Nectar flow estimate: moderate placeholder", systemImage: "drop.fill")
            Label("Swarm window alerts: informational placeholder", systemImage: "wind")
        }
        .foregroundStyle(.secondary)
    }
}

struct ReportPreviewView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "doc.richtext.fill").font(.largeTitle).foregroundStyle(.orange)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct UpgradeBanner: View {
    @Environment(LocalizationService.self) private var localization

    var body: some View {
        HStack {
            Label(localization.t(.upgradeBanner), systemImage: "crown.fill")
            Spacer()
            Image(systemName: "chevron.right")
        }
        .font(.subheadline.bold())
        .foregroundStyle(.black)
        .padding(14)
        .background(.orange, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage).font(.system(size: 44)).foregroundStyle(.orange)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(.black.opacity(0.38), in: RoundedRectangle(cornerRadius: 8))
    }
}
