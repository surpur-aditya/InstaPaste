import Combine
import SwiftUI
import UIKit

@MainActor
final class TemplatesViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedTag: String?
    @Published var sortOption: TemplateSortOption = .dateCreated
    @Published var layoutStyle: TemplateLayoutStyle = .list

    let store: TemplateStore
    private var cancellables = Set<AnyCancellable>()

    init(store: TemplateStore) {
        self.store = store
        store.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var filteredTemplates: [Template] {
        let filtered = store.templates.filter { template in
            let matchesSearch = searchText.isEmpty
                || template.title.localizedCaseInsensitiveContains(searchText)
                || template.content.localizedCaseInsensitiveContains(searchText)
                || template.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            let matchesTag = selectedTag == nil || template.tags.contains(selectedTag ?? "")
            return matchesSearch && matchesTag
        }

        return TemplateSortingService.sort(filtered, using: sortOption)
    }

    var availableTags: [String] {
        Array(Set(store.templates.flatMap(\.tags))).sorted()
    }

    func createTemplate(input: TemplateInput) {
        store.createTemplate(input: input)
    }

    func updateTemplate(_ template: Template, with input: TemplateInput) {
        store.updateTemplate(id: template.id, input: input)
    }

    func deleteTemplate(_ template: Template) {
        store.deleteTemplate(id: template.id)
    }

    func markTemplateUsed(_ template: Template) {
        store.markTemplateUsed(id: template.id)
        HapticsService.lightImpact()
    }

    func importTemplates(from url: URL, mode: TemplateImportMode) throws {
        let didAccessSecurityResource = url.startAccessingSecurityScopedResource()
        defer {
            if didAccessSecurityResource {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: url)
        let templates = try TemplateImportExportService.decodeTemplates(from: data)
        store.importTemplates(templates, mode: mode)
    }

    func makeExportDocument() throws -> TemplateExportDocument {
        TemplateExportDocument(data: try store.exportData())
    }
}

enum HapticsService {
    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
