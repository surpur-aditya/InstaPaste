import SwiftUI

struct TemplatesScreen: View {
    @EnvironmentObject private var viewModel: TemplatesViewModel
    @Binding var editingTemplate: Template?

    let onCreateTemplate: () -> Void

    private let gridColumns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.12), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                if viewModel.filteredTemplates.isEmpty {
                    EmptyStateView(
                        title: "No templates yet",
                        subtitle: "Create your first reusable paste block, then reuse it across apps and the keyboard extension.",
                        actionTitle: "Add",
                        action: onCreateTemplate
                    )
                } else {
                    content
                }
            }
        }
        .navigationTitle("InstaPaste")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search templates")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort", selection: $viewModel.sortOption) {
                        ForEach(TemplateSortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }

                Picker("Layout", selection: $viewModel.layoutStyle) {
                    ForEach(TemplateLayoutStyle.allCases) { layout in
                        Image(systemName: layout.iconName).tag(layout)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 110)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !viewModel.availableTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button {
                                viewModel.selectedTag = nil
                            } label: {
                                TagChip(title: "All", isSelected: viewModel.selectedTag == nil)
                            }
                            .buttonStyle(.plain)

                            ForEach(viewModel.availableTags, id: \.self) { tag in
                                Button {
                                    viewModel.selectedTag = viewModel.selectedTag == tag ? nil : tag
                                } label: {
                                    TagChip(title: tag, isSelected: viewModel.selectedTag == tag)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                switch viewModel.layoutStyle {
                case .list:
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredTemplates) { template in
                            templateRow(template)
                        }
                    }
                    .padding(.horizontal, 20)
                case .grid:
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(viewModel.filteredTemplates) { template in
                            templateGridItem(template)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
    }

    private func templateRow(_ template: Template) -> some View {
        TemplateCardView(template: template, style: .list)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.markTemplateUsed(template)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.deleteTemplate(template)
            } label: {
                Image(systemName: "trash")
            }

            Button {
                editingTemplate = template
            } label: {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                viewModel.toggleFavorite(template)
            } label: {
                Image(systemName: template.isFavorite ? "star.slash" : "star")
            }
            .tint(.yellow)
        }
    }

    private func templateGridItem(_ template: Template) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                viewModel.markTemplateUsed(template)
            } label: {
                TemplateCardView(template: template, style: .grid)
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Button {
                    editingTemplate = template
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    viewModel.deleteTemplate(template)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)

                Button {
                    viewModel.toggleFavorite(template)
                } label: {
                    Image(systemName: template.isFavorite ? "star.fill" : "star")
                }
                .buttonStyle(.bordered)
            }
            .font(.caption.weight(.semibold))
        }
    }
}

#Preview {
    let store = TemplateStore(previewMode: true)
    let viewModel = TemplatesViewModel(store: store)

    return NavigationStack {
        TemplatesScreen(
            editingTemplate: .constant(nil),
            onCreateTemplate: {}
        )
    }
    .environmentObject(store)
    .environmentObject(viewModel)
}
