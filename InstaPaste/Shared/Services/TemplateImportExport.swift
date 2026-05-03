import SwiftUI
import UniformTypeIdentifiers

struct TemplateExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

enum TemplateImportExportService {
    private struct Payload: Codable {
        let templates: [Template]
    }

    static func decodeTemplates(from data: Data) throws -> [Template] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let payload = try? decoder.decode(Payload.self, from: data) {
            return payload.templates
        }

        if let templates = try? decoder.decode([Template].self, from: data) {
            return templates
        }

        throw CocoaError(.fileReadCorruptFile)
    }

    static func encodeTemplates(_ templates: [Template]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(Payload(templates: templates))
    }
}
