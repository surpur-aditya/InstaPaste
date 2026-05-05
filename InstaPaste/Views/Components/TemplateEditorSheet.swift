import SwiftUI

struct TemplateEditorSheet: View {
    enum Mode {
        case create
        case edit

        var title: String {
            switch self {
            case .create: return "New Template"
            case .edit: return "Edit Template"
            }
        }

        var cta: String {
            switch self {
            case .create: return "Save"
            case .edit: return "Save"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var input: TemplateInput

    let mode: Mode
    let template: Template?
    let existingTags: [String]
    let onSave: (TemplateInput) -> Void

    init(
        mode: Mode,
        template: Template?,
        existingTags: [String],
        onSave: @escaping (TemplateInput) -> Void
    ) {
        self.mode = mode
        self.template = template
        self.existingTags = existingTags
        self.onSave = onSave
        _input = State(initialValue: TemplateInput(
            title: template?.title ?? "",
            content: template?.content ?? "",
            tagsText: template?.tags.joined(separator: ", ") ?? ""
        ))
    }

    private var formIsValid: Bool {
        !input.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !input.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        TextField("Title", text: $input.title)
                            .textInputAutocapitalization(.words)

                        TextField("Tags (comma separated)", text: $input.tagsText)
                            .textInputAutocapitalization(.never)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Content")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            TextEditor(text: $input.content)
                                .frame(minHeight: 220)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.secondary.opacity(0.08))
                                )
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.secondary.opacity(0.08))
                    )

                    if !existingTags.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Popular Tags")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                                ForEach(existingTags, id: \.self) { tag in
                                    Button {
                                        appendTag(tag)
                                    } label: {
                                        TagChip(title: tag)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.cta) {
                        onSave(input)
                        dismiss()
                    }
                    .disabled(!formIsValid)
                }
            }
        }
    }

    private func appendTag(_ tag: String) {
        var tags = Template.normalizedTags(input.tagsText.components(separatedBy: ","))
        guard tags.contains(tag) == false else { return }
        tags.append(tag)
        input.tagsText = tags.joined(separator: ", ")
    }
}
