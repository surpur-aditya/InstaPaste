import Combine
import Foundation

@MainActor
final class TemplateStore: ObservableObject {
    @Published private(set) var templates: [Template] = []

    private nonisolated static let templatesStorageKeyValue = "quickpaste.templates"
    private nonisolated static let templatesUpdatedNotificationValue = "group.alpacas.quickpaste.templates-updated"

    private let defaults: UserDefaults
    private let previewMode: Bool
    private let templatesFileURL: URL

    init(userDefaults: UserDefaults? = nil, previewMode: Bool = false, templatesFileURL: URL? = nil) {
        self.defaults = userDefaults ?? AppConfiguration.sharedUserDefaults()
        self.previewMode = previewMode
        self.templatesFileURL = templatesFileURL ?? AppConfiguration.templatesFileURL()
        loadTemplates(seedIfNeeded: !previewMode)
    }

    func loadTemplates(seedIfNeeded: Bool = false) {
        guard !previewMode else {
            templates = Template.sampleData
            return
        }

        guard let data = try? Data(contentsOf: templatesFileURL) else {
            if seedIfNeeded, defaults.bool(forKey: AppConfiguration.seedStorageKey) == false {
                templates = Template.sampleData
                defaults.set(true, forKey: AppConfiguration.seedStorageKey)
                persist()
            } else {
                templates = []
            }
            return
        }

        do {
            templates = try TemplateImportExportService.decodeTemplates(from: data)
        } catch {
            templates = []
        }
    }

    func createTemplate(input: TemplateInput) {
        let template = Template(
            title: input.title,
            content: input.content,
            tags: input.tags
        )
        templates.insert(template, at: 0)
        persist()
    }

    func updateTemplate(id: UUID, input: TemplateInput) {
        guard let index = templates.firstIndex(where: { $0.id == id }) else { return }
        templates[index].title = input.title.trimmingCharacters(in: .whitespacesAndNewlines)
        templates[index].content = input.content.trimmingCharacters(in: .whitespacesAndNewlines)
        templates[index].tags = input.tags
        persist()
    }

    func deleteTemplate(id: UUID) {
        templates.removeAll { $0.id == id }
        persist()
    }

    func toggleFavorite(id: UUID) {
        guard let index = templates.firstIndex(where: { $0.id == id }) else { return }
        templates[index].isFavorite.toggle()
        persist()
    }

    func markTemplateUsed(id: UUID) {
        guard let index = templates.firstIndex(where: { $0.id == id }) else { return }
        templates[index].usageCount += 1
        templates[index].lastUsedAt = .now
        persist()
    }

    func markTemplateUsedFromKeyboard(id: UUID) {
        guard let index = templates.firstIndex(where: { $0.id == id }) else { return }
        templates[index].usageCount += 1
        templates[index].lastUsedAt = .now
        persistAsyncSnapshot(templates)
    }

    func exportData() throws -> Data {
        try TemplateImportExportService.encodeTemplates(templates)
    }

    func importTemplates(_ importedTemplates: [Template], mode: TemplateImportMode) {
        switch mode {
        case .overwrite:
            templates = importedTemplates
        case .merge:
            var merged = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
            for template in importedTemplates {
                merged[template.id] = template
            }
            templates = Array(merged.values)
        }

        persist()
    }

    func keyboardTemplates() -> [Template] {
        TemplateSortingService.keyboardPriority(templates)
    }

    private func persist() {
        do {
            let data = try TemplateImportExportService.encodeTemplates(templates)
            try Self.write(
                data: data,
                to: templatesFileURL,
                defaults: defaults
            )
        } catch {
            assertionFailure("Failed to persist templates: \(error.localizedDescription)")
        }
    }

    private func persistAsyncSnapshot(_ snapshot: [Template]) {
        guard !previewMode else { return }

        let defaults = defaults
        let fileURL = templatesFileURL

        Task.detached(priority: .utility) {
            do {
                let data = try Self.encodeSnapshot(snapshot)
                try Self.write(
                    data: data,
                    to: fileURL,
                    defaults: defaults
                )
            } catch {
                assertionFailure("Failed to persist templates from keyboard: \(error.localizedDescription)")
            }
        }
    }

    nonisolated private static func encodeSnapshot(_ templates: [Template]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(["templates": templates])
    }

    nonisolated private static func write(data: Data, to fileURL: URL, defaults: UserDefaults) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: .atomic)
        defaults.set(Date().timeIntervalSince1970, forKey: templatesStorageKeyValue)
        defaults.synchronize()
        postTemplatesUpdatedNotification()
    }

    private func postTemplatesUpdatedNotification() {
        Self.postTemplatesUpdatedNotification()
    }

    nonisolated private static func postTemplatesUpdatedNotification() {
        let name = CFNotificationName(templatesUpdatedNotificationValue as CFString)
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), name, nil, nil, true)
    }
}
