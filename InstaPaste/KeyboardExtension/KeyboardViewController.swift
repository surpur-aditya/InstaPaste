import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController {
    private let store = TemplateStore()
    private var hostingController: UIHostingController<KeyboardTemplatesView>?
    private let notificationName = CFNotificationName(AppConfiguration.templatesUpdatedNotification as CFString)
    private var isObservingTemplateUpdates = false

    override func viewDidLoad() {
        super.viewDidLoad()
        embedKeyboard()
        refreshTemplates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForTemplateUpdates()
        refreshTemplates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForTemplateUpdates()
    }

    deinit {
        unregisterForTemplateUpdates()
    }

    private func embedKeyboard() {
        let keyboardView = KeyboardTemplatesView(
            store: store,
            onPaste: { [weak self] template in
                self?.insert(template)
            },
            onBackspace: { [weak self] in
                self?.handleBackspace()
            },
            onEnter: { [weak self] in
                self?.handleEnter()
            },
            onNextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            }
        )

        let hostingController = UIHostingController(rootView: keyboardView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }

    private func refreshTemplates() {
        store.loadTemplates()
    }

    private func registerForTemplateUpdates() {
        guard !isObservingTemplateUpdates else { return }
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, _, _, _ in
                guard let observer else { return }
                let controller = Unmanaged<KeyboardViewController>.fromOpaque(observer).takeUnretainedValue()
                Task { @MainActor in
                    controller.refreshTemplates()
                }
            },
            notificationName.rawValue,
            nil,
            .deliverImmediately
        )
        isObservingTemplateUpdates = true
    }

    private func unregisterForTemplateUpdates() {
        guard isObservingTemplateUpdates else { return }
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            notificationName,
            nil
        )
        isObservingTemplateUpdates = false
    }

    private func insert(_ template: Template) {
        textDocumentProxy.insertText(template.content)
        store.markTemplateUsedFromKeyboard(id: template.id)
        HapticsService.lightImpact()
    }

    private func handleBackspace() {
        textDocumentProxy.deleteBackward()
        HapticsService.lightImpact()
    }

    private func handleEnter() {
        textDocumentProxy.insertText("\n")
        HapticsService.lightImpact()
    }
}
