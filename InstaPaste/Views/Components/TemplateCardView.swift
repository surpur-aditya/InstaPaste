import SwiftUI

struct TemplateCardView: View {
    enum Style {
        case list
        case grid
    }

    let template: Template
    let style: Style
    var onToggleFavorite: (() -> Void)? = nil

    private var tagsLine: String? {
        guard template.tags.isEmpty == false else { return nil }
        return template.tags.map { "#\($0)" }.joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: style == .grid ? 10 : 12) {
            HStack(alignment: .top, spacing: 8) {
                Text(template.title)
                    .font(style == .grid ? .headline.weight(.semibold) : .headline)
                    .foregroundStyle(.primary)
                    .lineLimit(style == .grid ? 3 : 2)

                Spacer(minLength: 0)

                if onToggleFavorite != nil {
                    Button {
                        onToggleFavorite?()
                    } label: {
                        Image(systemName: template.isFavorite ? "star.fill" : "star")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(template.isFavorite ? Color.accentColor : .secondary)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground).opacity(0.92))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(template.previewText)
                .font(style == .grid ? .footnote : .subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(style == .grid ? 5 : 3)

            Spacer(minLength: 0)

            if let tagsLine {
                Text(tagsLine)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(style == .grid ? 2 : 1)
            }
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            minHeight: style == .grid ? 180 : nil,
            maxHeight: style == .grid ? 180 : nil,
            alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.accentColor.opacity(style == .grid ? 0.12 : 0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 18, y: 8)
        )
    }
}
