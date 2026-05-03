import Foundation
import Testing
@testable import InstaPaste

struct InstaPasteTests {
    @Test
    func keyboardSortingPrefersUsageThenRecentUse() {
        let olderMostUsed = Template(
            title: "A",
            content: "A",
            createdAt: .now.addingTimeInterval(-10_000),
            usageCount: 4,
            lastUsedAt: .now.addingTimeInterval(-1_000)
        )
        let recentLessUsed = Template(
            title: "B",
            content: "B",
            createdAt: .now,
            usageCount: 2,
            lastUsedAt: .now
        )
        let neverUsed = Template(
            title: "C",
            content: "C",
            createdAt: .now.addingTimeInterval(-100)
        )

        let sorted = TemplateSortingService.keyboardPriority([neverUsed, recentLessUsed, olderMostUsed])

        #expect(sorted.map(\.title) == ["A", "B", "C"])
    }

    @Test
    func importExportRoundTripPreservesTemplates() throws {
        let templates = Template.sampleData
        let data = try TemplateImportExportService.encodeTemplates(templates)
        let decoded = try TemplateImportExportService.decodeTemplates(from: data)

        #expect(decoded == templates)
    }

    @Test
    func keyboardExtensionPlistRequestsOpenAccess() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let plistURL = repositoryRoot
            .appendingPathComponent("InstaPaste")
            .appendingPathComponent("InstaPasteKeyboard-Info.plist")

        let data = try Data(contentsOf: plistURL)
        let plist = try #require(PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any])
        let extensionInfo = try #require(plist["NSExtension"] as? [String: Any])
        let attributes = try #require(extensionInfo["NSExtensionAttributes"] as? [String: Any])

        #expect(extensionInfo["NSExtensionPointIdentifier"] as? String == "com.apple.keyboard-service")
        #expect(attributes["RequestsOpenAccess"] as? Bool == true)
    }

    @MainActor
    @Test
    func creatingTemplateImmediatelyUpdatesStoreAndKeyboardData() {
        let suiteName = "InstaPasteTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(true, forKey: AppConfiguration.seedStorageKey)
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(suiteName)-templates.json")
        try? FileManager.default.removeItem(at: fileURL)

        let store = TemplateStore(userDefaults: defaults, templatesFileURL: fileURL)
        let viewModel = TemplatesViewModel(store: store)
        let input = TemplateInput(
            title: "Fresh Template",
            content: "This should be visible immediately",
            tagsText: "quick"
        )

        viewModel.createTemplate(input: input)

        #expect(viewModel.filteredTemplates.first?.title == "Fresh Template")
        #expect(store.keyboardTemplates().contains(where: { $0.title == "Fresh Template" }))
    }
}
