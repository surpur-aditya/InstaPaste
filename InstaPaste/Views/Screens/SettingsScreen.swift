import SwiftUI
import UniformTypeIdentifiers

struct SettingsScreen: View {
    @EnvironmentObject private var viewModel: TemplatesViewModel
    @AppStorage("appearanceMode") private var appearanceModeRawValue = AppearanceMode.system.rawValue
    @State private var importMode: TemplateImportMode = .merge
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var exportDocument = TemplateExportDocument(data: Data())
    @State private var alertMessage: String?

    var body: some View {
        List {
            Section("Appearance") {
                Picker("Theme", selection: $appearanceModeRawValue) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Import / Export") {
                Picker("Import Mode", selection: $importMode) {
                    ForEach(TemplateImportMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }

                Button("Import Templates") {
                    isImporting = true
                }

                Button("Export Templates") {
                    do {
                        exportDocument = try viewModel.makeExportDocument()
                        isExporting = true
                    } catch {
                        alertMessage = "Export failed. \(error.localizedDescription)"
                    }
                }
            }

            Section("Privacy") {
                Label("No internet required", systemImage: "wifi.slash")
                Label("No tracking or analytics", systemImage: "hand.raised")
                Label("All data stays on-device", systemImage: "internaldrive")
            }

            Section("Keyboard Setup") {
                Text("Go to Settings > General > Keyboard > Keyboards > Add New Keyboard, choose InstaPaste, then tap InstaPaste and enable Allow Full Access so the keyboard can read your saved templates from the shared app group.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                Text(AppConfiguration.appVersionDescription)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundStyle(.secondary)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Settings")
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                let url = try result.get().first!
                try viewModel.importTemplates(from: url, mode: importMode)
                alertMessage = "Templates imported successfully."
            } catch {
                alertMessage = "Import failed. Please verify the JSON structure."
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "instapaste-templates"
        ) { result in
            switch result {
            case .success:
                alertMessage = "Export created successfully."
            case let .failure(error):
                alertMessage = "Export failed. \(error.localizedDescription)"
            }
        }
        .alert("InstaPaste", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }
}
