import Foundation

enum TemplateSortOption: String, CaseIterable, Identifiable {
    case alphabetical
    case dateCreated

    var id: String { rawValue }

    var title: String {
        switch self {
        case .alphabetical: return "A-Z"
        case .dateCreated: return "Recent"
        }
    }
}

enum TemplateLayoutStyle: String, CaseIterable, Identifiable {
    case list
    case grid

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}

enum TemplateImportMode: String, CaseIterable, Identifiable {
    case merge
    case overwrite

    var id: String { rawValue }

    var title: String {
        switch self {
        case .merge: return "Merge"
        case .overwrite: return "Overwrite"
        }
    }
}

enum TemplateSortingService {
    static func sort(_ templates: [Template], using option: TemplateSortOption) -> [Template] {
        switch option {
        case .alphabetical:
            return templates.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .dateCreated:
            return templates.sorted { $0.createdAt > $1.createdAt }
        }
    }

    static func keyboardPriority(_ templates: [Template]) -> [Template] {
        templates.sorted { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite && !rhs.isFavorite
            }
            if lhs.usageCount != rhs.usageCount {
                return lhs.usageCount > rhs.usageCount
            }

            switch (lhs.lastUsedAt, rhs.lastUsedAt) {
            case let (left?, right?) where left != right:
                return left > right
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            default:
                return lhs.createdAt > rhs.createdAt
            }
        }
    }
}
