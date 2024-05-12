import Cocoa

class WaitronWindow: NSWindow {
    init(viewController: NSViewController, cornerRadius: CGFloat, visualEffectMaterial: NSVisualEffectView.Material) {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false

        let effectView = NSVisualEffectView()
        effectView.material = visualEffectMaterial
        effectView.blendingMode = .behindWindow
        effectView.autoresizingMask = [.height, .width]
        effectView.isEmphasized = true
        effectView.state = .active
        view.addSubview(effectView)

        view.addSubview(viewController.view)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let contentRect = CGRect(origin: .zero, size: view.fittingSize)

        super.init(contentRect: contentRect, styleMask: [.borderless], backing: .buffered, defer: false)

        self.hasShadow = true
        self.backgroundColor = .clear
        self.isMovable = false
        self.level = .popUpMenu
        self.isExcludedFromWindowsMenu = true
        self.tabbingMode = .disallowed

        self.contentView = view
    }
}
