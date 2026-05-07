import SwiftUI

enum KeyboardTemplateFilter: String, CaseIterable, Identifiable {
    case all
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        }
    }
}

struct KeyboardTemplatesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var store: TemplateStore
    @State private var selectedFilter: KeyboardTemplateFilter = .all

    let onPaste: (Template) -> Void
    let onBackspace: () -> Void
    let onEnter: () -> Void
    let onNextKeyboard: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 10)]

    private var visibleTemplates: [Template] {
        switch selectedFilter {
        case .all:
            return TemplateSortingService.keyboardAllPriority(store.templates)
        case .favorites:
            return TemplateSortingService.keyboardPriority(store.templates.filter(\.isFavorite))
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("InstaPaste")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(colorScheme == .dark ? .white : .primary)

                Spacer(minLength: 0)

                filterControls

                KeyboardActionButton(action: onNextKeyboard) {
                    Image(systemName: "globe")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.75)))
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)
                }
            }
            .padding(.horizontal, 14)

            if store.templates.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "text.badge.plus")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)

                    Text("No templates")
                        .font(.headline)

                    Text("Create templates in the app first.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .padding(.horizontal, 14)
            } else if visibleTemplates.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "star")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)

                    Text("No favorites yet")
                        .font(.headline)

                    Text("Mark templates as favorites in the app to pin them here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .padding(.horizontal, 14)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(visibleTemplates) { template in
                            templateTile(template)
                                .onTapGesture {
                                onPaste(template)
                                }
                                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                }
            }

            HStack(spacing: 10) {
                RepeatingKeyboardActionButton(
                    action: onBackspace,
                    initialDelay: 0.35,
                    repeatInterval: 0.08
                ) {
                    keySurface(
                        systemImage: "delete.left",
                        foregroundColor: colorScheme == .dark ? .white : .primary,
                        backgroundColor: Color.white.opacity(colorScheme == .dark ? 0.12 : 0.78)
                    )
                }

                KeyboardActionButton(action: onEnter) {
                    keySurface(
                        systemImage: "return",
                        foregroundColor: .white,
                        backgroundColor: Color.accentColor.opacity(0.92)
                    )
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(AppTheme.keyboardBackground(for: colorScheme))
    }

    private var filterControls: some View {
        HStack(spacing: 6) {
            ForEach(KeyboardTemplateFilter.allCases) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter.title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(selectedFilter == filter ? .white : (colorScheme == .dark ? .white : .primary))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(
                                    selectedFilter == filter
                                    ? Color.accentColor
                                    : Color.white.opacity(colorScheme == .dark ? 0.12 : 0.74)
                                )
                        )
                }
            }
        }
    }

    private func templateTile(_ template: Template) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(template.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Text(template.previewText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if !template.tags.isEmpty {
                Text(template.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(2)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.84))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.4), lineWidth: 1)
                )
        )
    }

    private func keySurface(
        systemImage: String,
        foregroundColor: Color,
        backgroundColor: Color
    ) -> some View {
        Image(systemName: systemImage)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor)
            )
            .foregroundStyle(foregroundColor)
    }
}

private struct KeyboardActionButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        label()
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
            .accessibilityAddTraits(.isButton)
    }
}

private struct RepeatingKeyboardActionButton<Label: View>: View {
    let action: () -> Void
    let initialDelay: TimeInterval
    let repeatInterval: TimeInterval
    @ViewBuilder let label: () -> Label

    @State private var repeatingTask: Task<Void, Never>?

    var body: some View {
        label()
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard repeatingTask == nil else { return }
                        action()
                        repeatingTask = Task {
                            try? await Task.sleep(for: .seconds(initialDelay))
                            while !Task.isCancelled {
                                await MainActor.run {
                                    action()
                                }
                                try? await Task.sleep(for: .seconds(repeatInterval))
                            }
                        }
                    }
                    .onEnded { _ in
                        stopRepeating()
                    }
            )
            .onDisappear {
                stopRepeating()
            }
            .accessibilityAddTraits(.isButton)
    }

    private func stopRepeating() {
        repeatingTask?.cancel()
        repeatingTask = nil
    }
}
