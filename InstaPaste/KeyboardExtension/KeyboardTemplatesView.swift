import SwiftUI

struct KeyboardTemplatesView: View {
    let templates: [Template]
    let onPaste: (Template) -> Void
    let onNextKeyboard: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 10)]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("InstaPaste")
                    .font(.headline)

                Spacer()

                Button(action: onNextKeyboard) {
                    Image(systemName: "globe")
                        .font(.headline)
                        .padding(10)
                        .background(Circle().fill(Color.secondary.opacity(0.14)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)

            if templates.isEmpty {
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
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(templates) { template in
                            Button {
                                onPaste(template)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(template.title)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(1)

                                    Text(template.previewText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)

                                    if !template.tags.isEmpty {
                                        Text(template.tags.map { "#\($0)" }.joined(separator: " "))
                                            .font(.caption2.weight(.medium))
                                            .foregroundStyle(Color.accentColor)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
                }
            }
        }
        .padding(.top, 10)
        .background(Color(.systemBackground))
    }
}
