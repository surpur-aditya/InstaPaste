import Foundation

struct Template: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var content: String
    var tags: [String]
    var createdAt: Date
    var usageCount: Int
    var lastUsedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        tags: [String] = [],
        createdAt: Date = .now,
        usageCount: Int = 0,
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.tags = Template.normalizedTags(tags)
        self.createdAt = createdAt
        self.usageCount = usageCount
        self.lastUsedAt = lastUsedAt
    }

    var previewText: String {
        content.replacingOccurrences(of: "\n", with: " ")
    }

    static func normalizedTags(_ tags: [String]) -> [String] {
        Array(
            Set(
                tags
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                    .filter { !$0.isEmpty }
            )
        )
        .sorted()
    }
}

extension Template {
    static let sampleData: [Template] = [
        Template(
            title: "Follow-up Email",
            content: "Hi there,\n\nJust following up on the note below. Let me know if you need anything else from me.\n\nBest,\nAditya",
            tags: ["email", "work"],
            createdAt: .now.addingTimeInterval(-86_400 * 3)
        ),
        Template(
            title: "Meeting Summary",
            content: "Thanks for the time today. Here is a quick recap:\n• Goals aligned\n• Timeline confirmed\n• Next step: final review on Friday",
            tags: ["meeting", "team"],
            createdAt: .now.addingTimeInterval(-86_400 * 2),
            usageCount: 2,
            lastUsedAt: .now.addingTimeInterval(-6_000)
        ),
        Template(
            title: "Shipping Reply",
            content: "Your order is packed and scheduled for pickup today. I’ll send tracking as soon as it updates.",
            tags: ["support", "shop"],
            createdAt: .now.addingTimeInterval(-86_400),
            usageCount: 5,
            lastUsedAt: .now.addingTimeInterval(-1_800)
        )
    ]
}

struct TemplateInput {
    var title: String
    var content: String
    var tagsText: String

    var tags: [String] {
        Template.normalizedTags(tagsText.components(separatedBy: ","))
    }
}
