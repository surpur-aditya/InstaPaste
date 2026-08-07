import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: TemplatesViewModel
    @State private var selectedTab: RootTab = .templates
    @State private var isPresentingComposer = false
    @State private var editingTemplate: Template?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .templates:
                    NavigationStack {
                        TemplatesScreen(
                            editingTemplate: $editingTemplate,
                            onCreateTemplate: { isPresentingComposer = true }
                        )
                    }
                case .settings:
                    NavigationStack {
                        SettingsScreen()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            bottomNavigationBar
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(.regularMaterial)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $isPresentingComposer) {
            TemplateEditorSheet(
                mode: .create,
                template: nil,
                existingTags: viewModel.availableTags
            ) { input in
                viewModel.createTemplate(input: input)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingTemplate) { template in
            TemplateEditorSheet(
                mode: .edit,
                template: template,
                existingTags: viewModel.availableTags
            ) { input in
                viewModel.updateTemplate(template, with: input)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var bottomNavigationBar: some View {
        HStack(spacing: 10) {
            tabButton(tab: .templates, title: "Templates", systemImage: "square.grid.2x2")
                .frame(maxWidth: .infinity)

            floatingAddButton
                .frame(width: 64, height: 64)

            tabButton(tab: .settings, title: "Settings", systemImage: "gearshape")
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: 360)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.10), radius: 24, y: 10)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func tabButton(tab: RootTab, title: String, systemImage: String) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(
                Capsule()
                    .fill(isSelected ? Color(.systemBackground).opacity(0.62) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private var floatingAddButton: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                isPresentingComposer = true
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .frame(width: 64, height: 64)
                .background(Circle().fill(Color.accentColor))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }
}

private enum RootTab: Hashable {
    case templates
    case settings
}

#Preview {
    let store = TemplateStore(previewMode: true)
    let viewModel = TemplatesViewModel(store: store)

    return ContentView()
        .environmentObject(store)
        .environmentObject(viewModel)
}
