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

enum AppTheme {
    static let deepTeal = Color(red: 39 / 255, green: 60 / 255, blue: 61 / 255)
    static let teal = Color(red: 89 / 255, green: 145 / 255, blue: 141 / 255)
    static let mint = Color(red: 163 / 255, green: 205 / 255, blue: 197 / 255)
    static let paleMint = Color(red: 219 / 255, green: 236 / 255, blue: 217 / 255)
    static let tagFill = mint.opacity(0.18)

    static func appBackground(for colorScheme: ColorScheme?) -> LinearGradient {
        let top = colorScheme == .dark ? deepTeal.opacity(0.92) : paleMint.opacity(0.35)
        let bottom = colorScheme == .dark ? teal.opacity(0.38) : Color(.systemBackground)
        return LinearGradient(colors: [top, bottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func keyboardBackground(for colorScheme: ColorScheme?) -> LinearGradient {
        let top = colorScheme == .dark ? deepTeal : deepTeal.opacity(0.95)
        let bottom = colorScheme == .dark ? teal.opacity(0.45) : mint.opacity(0.35)
        return LinearGradient(colors: [top, bottom], startPoint: .topLeading, endPoint: .bottomTrailing)
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
