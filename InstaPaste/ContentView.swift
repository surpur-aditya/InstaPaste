import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: TemplatesViewModel
    @State private var selectedTab: RootTab = .templates
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
                    Label {
                        Text("Add")
                    } icon: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.accentColor))
                            .foregroundStyle(.white)
                    }
                }
                .tag(RootTab.add)

            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(RootTab.settings)
        }
        .onChange(of: selectedTab) { newValue in
            guard newValue == .add else { return }
            selectedTab = .templates
            isPresentingComposer = true
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
}

private enum RootTab: Hashable {
    case templates
    case add
    case settings
}

#Preview {
    let store = TemplateStore(previewMode: true)
    let viewModel = TemplatesViewModel(store: store)

    return ContentView()
        .environmentObject(store)
        .environmentObject(viewModel)
}
