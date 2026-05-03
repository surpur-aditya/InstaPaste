import SwiftUI

enum AppConfiguration {
    static let appGroupIdentifier = "group.alpacas.quickpaste"
    static let templatesStorageKey = "quickpaste.templates"
    static let seedStorageKey = "quickpaste.didSeed"
    static let templatesUpdatedNotification = "group.alpacas.quickpaste.templates-updated"

    static func sharedUserDefaults() -> UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    static func storageDirectoryURL() -> URL {
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return containerURL
        }

        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    static func templatesFileURL() -> URL {
        storageDirectoryURL().appendingPathComponent("templates.json")
    }

    static var appVersionDescription: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
