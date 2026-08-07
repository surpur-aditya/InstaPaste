import SwiftUI

struct TemplatesScreen: View {
    @EnvironmentObject private var viewModel: TemplatesViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var editingTemplate: Template?

    let onCreateTemplate: () -> Void

    private let gridColumns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ZStack {
            AppTheme.appBackground(for: colorScheme)
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
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search templates"
        )
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
        switch viewModel.layoutStyle {
        case .list:
            List {
                if !viewModel.availableTags.isEmpty {
                    tagsFilterBar
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                ForEach(viewModel.filteredTemplates) { template in
                    templateRow(template)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        case .grid:
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if !viewModel.availableTags.isEmpty {
                        tagsFilterBar
                    }

                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(viewModel.filteredTemplates) { template in
                            templateGridItem(template)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
        }
    }

    private var tagsFilterBar: some View {
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

    private func templateRow(_ template: Template) -> some View {
        TemplateCardView(
            template: template,
            style: .list,
            onToggleFavorite: {
                viewModel.toggleFavorite(template)
            }
        )
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.markTemplateUsed(template)
            }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                viewModel.toggleFavorite(template)
            } label: {
                Image(systemName: template.isFavorite ? "star.slash" : "star")
            }
            .tint(.yellow)

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
    }

    private func templateGridItem(_ template: Template) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                viewModel.markTemplateUsed(template)
            } label: {
                TemplateCardView(
                    template: template,
                    style: .grid,
                    onToggleFavorite: {
                        viewModel.toggleFavorite(template)
                    }
                )
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Button {
                    editingTemplate = template
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.bordered)
                .frame(width: 44)

                Button(role: .destructive) {
                    viewModel.deleteTemplate(template)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .frame(width: 44)
            }
            .font(.caption.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .center)
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
