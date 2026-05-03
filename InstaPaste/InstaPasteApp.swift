import SwiftUI

@main
struct InstaPasteMainApp: App {
    @StateObject private var store: TemplateStore
    @StateObject private var viewModel: TemplatesViewModel
    @AppStorage("appearanceMode") private var appearanceModeRawValue = AppearanceMode.system.rawValue

    init() {
        let store = TemplateStore()
        _store = StateObject(wrappedValue: store)
        _viewModel = StateObject(wrappedValue: TemplatesViewModel(store: store))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(viewModel)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRawValue)?.colorScheme)
        }
    }
}
