//
//  PreferencesPanel.swift
//  SystemTracker
//
//  Created by Luka Managadze on 21/04/2026.
//


import SwiftUI
import AppKit

private final class PreferencesPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class PreferencesPanelController {
    static let shared = PreferencesPanelController()

    private var panel: NSPanel?
    private var localEventMonitor: Any?
    private var globalEventMonitor: Any?

    private init() {}

    func show() {
        let panel = panel ?? makePanel()
        self.panel = panel

        NSApp.activate(ignoringOtherApps: true)
        centerOnActiveDesktop(panel)
        prepareAppearAnimation(for: panel)
        panel.makeKeyAndOrderFront(nil)
        runAppearAnimation(for: panel)
        installDismissMonitors(for: panel)
    }

    private func makePanel() -> NSPanel {
        let panel = PreferencesPanel(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 360),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = NSHostingController(rootView: PreferencesView())
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.cornerRadius = 24
        panel.contentView?.layer?.masksToBounds = true
        panel.isMovableByWindowBackground = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = true
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.transient, .moveToActiveSpace, .fullScreenAuxiliary]
        panel.animationBehavior = .utilityWindow

        return panel
    }

    private func centerOnActiveDesktop(_ panel: NSPanel) {
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
            ?? NSScreen.main

        guard let targetScreen else {
            panel.center()
            return
        }

        let visibleFrame = targetScreen.visibleFrame
        let panelSize = panel.frame.size
        let centeredOrigin = NSPoint(
            x: visibleFrame.midX - (panelSize.width / 2),
            y: visibleFrame.midY - (panelSize.height / 2)
        )

        panel.setFrameOrigin(centeredOrigin)
    }

    private func prepareAppearAnimation(for panel: NSPanel) {
        panel.alphaValue = 0

        let finalFrame = panel.frame
        let scale: CGFloat = 0.96
        let scaledSize = NSSize(
            width: finalFrame.width * scale,
            height: finalFrame.height * scale
        )
        let startFrame = NSRect(
            x: finalFrame.midX - scaledSize.width / 2,
            y: finalFrame.midY - scaledSize.height / 2 - 8,
            width: scaledSize.width,
            height: scaledSize.height
        )

        panel.setFrame(startFrame, display: false)
    }

    private func runAppearAnimation(for panel: NSPanel) {
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
            ?? NSScreen.main

        guard let targetScreen else {
            panel.alphaValue = 1
            return
        }

        let visibleFrame = targetScreen.visibleFrame
        let finalSize = NSSize(width: 500, height: 360)
        let finalFrame = NSRect(
            x: visibleFrame.midX - finalSize.width / 2,
            y: visibleFrame.midY - finalSize.height / 2,
            width: finalSize.width,
            height: finalSize.height
        )

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrame(finalFrame, display: true)
        }
    }

    private func installDismissMonitors(for panel: NSPanel) {
        removeDismissMonitors()

        let mouseEvents: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        let monitoredEvents = mouseEvents.union(.keyDown)

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: monitoredEvents) { [weak self, weak panel] event in
            guard let self, let panel else { return event }

            if event.type == .keyDown, event.keyCode == 53 {
                panel.close()
                self.removeDismissMonitors()
                return nil
            }

            guard panel.isVisible else {
                self.removeDismissMonitors()
                return event
            }

            if event.window !== panel {
                panel.close()
                self.removeDismissMonitors()
            }

            return event
        }

        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: mouseEvents) { [weak self, weak panel] _ in
            guard let self, let panel else { return }

            if panel.isVisible {
                panel.close()
            }
            self.removeDismissMonitors()
        }
    }

    private func removeDismissMonitors() {
        if let localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }

        if let globalEventMonitor {
            NSEvent.removeMonitor(globalEventMonitor)
            self.globalEventMonitor = nil
        }
    }
}
