import Carbon.HIToolbox
import Cocoa

public final class Waitron<T: NSViewController> {
    private var windowController: WaitronWindowController?
    private var eventMonitor: Any?

    public let viewController: T

    public var cornerRadius: CGFloat = 5
    public var visualEffectMaterial: NSVisualEffectView.Material = .menu
    public var largestExpectedHeight: CGFloat? {
        didSet {
            self.windowController?.largestExpectedHeight = self.largestExpectedHeight
        }
    }

    public init(viewController: T) {
        self.viewController = viewController
    }

    deinit {
        self.stopEventMonitoring()
        self.windowController?.close()
    }

    public func show(anchoredTo rect: NSRect, for parentWindow: NSWindow) {
        let windowController = self.provideWindowController()
        windowController.showWindow(anchoredTo: rect, for: parentWindow)
        self.monitorEvents()
    }

    public func show(anchoredTo point: NSPoint, for parentWindow: NSWindow) {
        let rect = NSRect(origin: point, size: .zero)
        self.show(anchoredTo: rect, for: parentWindow)
    }

    public func hide() {
        self.windowController?.hideWindow()
        self.stopEventMonitoring()
    }

    private func monitorEvents() {
        guard self.eventMonitor == nil else {
            return
        }

        let events: NSEvent.EventTypeMask = [
            .leftMouseDown,
            .rightMouseDown,
            .otherMouseDown,
            .keyDown,
            .appKitDefined,
        ]
        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: events) { [weak self] event in
            guard
                let self = self,
                let eventWindow = event.window,
                let popupWindow = self.windowController?.window
            else {
                return event
            }

            switch event.type {
            case .appKitDefined, .leftMouseDown, .rightMouseDown, .otherMouseDown:
                if eventWindow != popupWindow {
                    self.hide()
                }
            case .keyDown:
                if Int(event.keyCode) == kVK_Escape, eventWindow == popupWindow.parent {
                    self.hide()
                    return nil
                }
            default:
                break
            }

            return event
        }
    }

    private func stopEventMonitoring() {
        if let eventMonitor = self.eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    private func provideWindowController() -> WaitronWindowController {
        if let windowController = self.windowController {
            return windowController
        }

        return self.makeWindowController()
    }

    private func makeWindowController() -> WaitronWindowController {
        let windowController = WaitronWindowController(
            viewController: self.viewController,
            cornerRadius: self.cornerRadius,
            visualEffectMaterial: self.visualEffectMaterial
        )
        windowController.largestExpectedHeight = self.largestExpectedHeight
        self.windowController = windowController

        return windowController
    }
}
