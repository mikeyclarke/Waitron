import Cocoa

class WaitronWindowController: NSWindowController {
    private var anchor: NSRect?

    public var largestExpectedHeight: CGFloat?

    init(viewController: NSViewController, cornerRadius: CGFloat, visualEffectMaterial: NSVisualEffectView.Material) {
        let window = WaitronWindow(
            viewController: viewController,
            cornerRadius: cornerRadius,
            visualEffectMaterial: visualEffectMaterial
        )

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.stopMonitoringResize()
    }

    func showWindow(anchoredTo rect: NSRect, for parentWindow: NSWindow) {
        guard let window = self.window else {
            return
        }

        self.anchor = rect

        if !window.isVisible {
            parentWindow.addChildWindow(window, ordered: .above)
        }

        guard let screen = parentWindow.screen else {
            return
        }

        self.position(window, anchoredTo: rect, in: screen)
        self.monitorResize()
    }

    func hideWindow() {
        guard let window = self.window else {
            return
        }

        window.orderOut(self)
        self.stopMonitoringResize()
    }

    func position(_ window: NSWindow, anchoredTo rect: NSRect, in screen: NSScreen) {
        guard let contentView = window.contentView else {
            return
        }

        let contentSize = contentView.fittingSize

        // swiftlint:disable identifier_name
        let x: CGFloat
        // swiftlint:enable identifier_name
        switch NSApp.userInterfaceLayoutDirection {
        case .rightToLeft:
            x = rect.minX - contentSize.width
        default:
            x = rect.minX
        }

        let visibleFrame = screen.visibleFrame

        var popupRect = NSRect(
            x: x,
            y: rect.minY - contentSize.height,
            width: contentSize.width,
            height: contentSize.height
        )

        var positioningHeight = contentSize.height
        if let largestExpectedHeight = self.largestExpectedHeight, largestExpectedHeight > positioningHeight {
            positioningHeight = largestExpectedHeight
        }
        var positioningRect = popupRect
        positioningRect.origin.y = rect.minY - positioningHeight
        positioningRect.size.height = positioningHeight

        if positioningRect.minY < visibleFrame.minY {
            popupRect.origin.y = rect.maxY
        }

        if popupRect.maxX > visibleFrame.maxX {
            popupRect.origin.x -= (popupRect.maxX - visibleFrame.maxX)
        }

        if popupRect.minX < visibleFrame.minX {
            popupRect.origin.x = visibleFrame.minX
        }

        window.setFrameOrigin(popupRect.origin)
    }

    private func monitorResize() {
        guard let window = self.window else {
            return
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize(_:)),
            name: NSWindow.didResizeNotification,
            object: window
        )
    }

    private func stopMonitoringResize() {
        guard let window = self.window else {
            return
        }

        NotificationCenter.default.removeObserver(self, name: NSWindow.didResizeNotification, object: window)
    }

    @objc private func windowDidResize(_ notification: Notification) {
        guard let window = self.window, let screen = window.screen, let rect = self.anchor else {
            return
        }

        self.position(window, anchoredTo: rect, in: screen)
    }
}
