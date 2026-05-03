import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController {
    private let store = TemplateStore()
    private var hostingController: UIHostingController<KeyboardTemplatesView>?
    private let notificationName = CFNotificationName(AppConfiguration.templatesUpdatedNotification as CFString)

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForTemplateUpdates()
        embedKeyboard()
        refreshTemplates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTemplates()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTemplates()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        refreshTemplates()
    }

    deinit {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            notificationName,
            nil
        )
    }

    private func embedKeyboard() {
        let keyboardView = KeyboardTemplatesView(
            templates: store.keyboardTemplates(),
            onPaste: { [weak self] template in
                self?.insert(template)
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

    private func updateKeyboard() {
        hostingController?.rootView = KeyboardTemplatesView(
            templates: store.keyboardTemplates(),
            onPaste: { [weak self] template in
                self?.insert(template)
            },
            onNextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            }
        )
    }

    private func refreshTemplates() {
        store.loadTemplates()
        updateKeyboard()
    }

    private func registerForTemplateUpdates() {
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
    }

    private func insert(_ template: Template) {
        textDocumentProxy.insertText(template.content)
        store.markTemplateUsed(id: template.id)
        HapticsService.lightImpact()
        updateKeyboard()
    }
}
