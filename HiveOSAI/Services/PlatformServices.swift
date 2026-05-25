import AVFoundation
import Foundation
import PhotosUI
import StoreKit
import SwiftUI
import UIKit
import UserNotifications

@Observable
@MainActor
final class StoreKitService {
    private let productIDs = [
        "hiveosai.premium.monthly",
        "hiveosai.premium.yearly",
        "hiveosai.apiarypro.monthly"
    ]

    var products: [Product] = []
    var activePlan: SubscriptionPlan = .free
    var isLoading = false
    var errorMessage: String?

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: productIDs)
            await refreshEntitlements()
        } catch {
            errorMessage = "StoreKit products are unavailable in this environment."
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified(let transaction) = verification {
                activePlan = product.id.contains("apiarypro") ? .apiaryPro : .premium
                await transaction.finish()
            }
        } catch {
            errorMessage = "Purchase could not be completed."
        }
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                activePlan = transaction.productID.contains("apiarypro") ? .apiaryPro : .premium
            }
        }
    }
}

@Observable
@MainActor
final class NotificationService {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        await refresh()
    }

    func refresh() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func scheduleInspectionReminder(title: String = "Hive inspection due") {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Review hive notes, photos, queen status, and food stores before conditions change."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

enum PDFReportService {
    static func makeReport(hive: Hive?, apiary: Apiary?, reportType: String) throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let url = FileManager.default.temporaryDirectory.appending(path: "HiveOS-\(reportType.replacingOccurrences(of: " ", with: "-"))-\(UUID().uuidString).pdf")
        try renderer.writePDF(to: url) { context in
            context.beginPage()
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 28, weight: .bold), .foregroundColor: UIColor.systemOrange]
            let bodyAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.label]
            "HiveOS AI \(reportType)".draw(at: CGPoint(x: 48, y: 48), withAttributes: titleAttributes)
            let body = """
            Informational agricultural insights only.
            Not veterinary advice. Not guaranteed disease detection.
            Users should independently verify hive decisions.

            Apiary: \(apiary?.name ?? hive?.apiary?.name ?? "Unassigned")
            Hive: \(hive?.hiveName ?? "All hives")
            Status: \(hive?.status.rawValue ?? "Overview")
            Health Score: \(hive?.hiveStrength ?? 0)
            Queen Status: \(hive?.queenAge ?? "Placeholder")
            Honey Production Estimate: \(String(format: "%.1f", hive?.honeyProductionEstimate ?? 0)) kg

            Summary:
            This PDF is generated locally from SwiftData records and mock AI placeholders. It is designed for operational review, inspection planning, and record keeping.
            """
            body.draw(in: CGRect(x: 48, y: 104, width: 516, height: 620), withAttributes: bodyAttributes)
        }
        return url
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onImageData: (Data) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageData: onImageData, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImageData: (Data) -> Void
        let dismiss: DismissAction

        init(onImageData: @escaping (Data) -> Void, dismiss: DismissAction) {
            self.onImageData = onImageData
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.82) {
                onImageData(data)
            }
            dismiss()
        }
    }
}

@Observable
final class AudioRecorderPlaceholder {
    var isRecording = false
    var currentPlaceholder = "hive-audio-placeholder.m4a"

    func toggleRecording() {
        isRecording.toggle()
        if !isRecording {
            currentPlaceholder = "hive-audio-\(Int(Date().timeIntervalSince1970)).m4a"
        }
    }
}
