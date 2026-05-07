import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: TemplatesViewModel
    @State private var selectedTab: RootTab = .templates
    @State private var lastContentTab: RootTab = .templates
    @State private var isPresentingComposer = false
    @State private var editingTemplate: Template?

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TemplatesScreen(
                    editingTemplate: $editingTemplate,
                    onCreateTemplate: { isPresentingComposer = true }
                )
            }
            .tabItem {
                Label("Templates", systemImage: "square.grid.2x2")
            }
            .tag(RootTab.templates)

            Color.clear
                .tabItem {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .opacity(0)
                }
                .tag(RootTab.compose)

            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(RootTab.settings)
        }
        .overlay(alignment: .bottom) {
            floatingAddButton
        }
        .onChange(of: selectedTab) { newValue in
            switch newValue {
            case .compose:
                selectedTab = lastContentTab
                isPresentingComposer = true
            case .templates, .settings:
                lastContentTab = newValue
            }
        }
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

    private var floatingAddButton: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                isPresentingComposer = true
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .frame(width: 58, height: 58)
                .background(Circle().fill(Color.accentColor))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 8)
    }
}

private enum RootTab: Hashable {
    case templates
    case compose
    case settings
}

#Preview {
    let store = TemplateStore(previewMode: true)
    let viewModel = TemplatesViewModel(store: store)

    return ContentView()
        .environmentObject(store)
        .environmentObject(viewModel)
}
