import SwiftUI
import Foundation

@main
struct VRAMTunerApp: App {
    @StateObject private var appDelegate = AppDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var viewModel = VRAMViewModel()
    private var statusBarItem: NSStatusItem?

    override init() {
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        viewModel.refreshVRAM()
    }

    private func setupMenuBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "gpu", accessibilityDescription: "VRAM Tuner")
            button.action = #selector(toggleWindow)
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Window", action: #selector(toggleWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit VRAM Tuner", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem?.menu = menu
    }

    @objc private func toggleWindow() {
        if let window = NSApplication.shared.windows.first {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}

class VRAMViewModel: ObservableObject {
    @Published var currentVRAM: Int = 0
    @Published var totalRAM: Int = 0
    @Published var recommendedVRAM: Int = 0
    @Published var allocatedVRAM: String = ""
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = ""
    @Published var errorMessage: String? = nil
    @Published var CPUReserve: Int = 8192 // 8GB default

    func refreshVRAM() {
        isLoading = true

        // Get total RAM
        var mem: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &mem, &size, nil, 0)
        totalRAM = Int(mem / 1024 / 1024)

        // Get current allocated VRAM
        var vramMB: Int32 = 0
        size = MemoryLayout<Int32>.size
        let result = sysctlbyname("iogpu.wired_limit_mb", &vramMB, &size, nil, 0)

        if result == 0 {
            currentVRAM = Int(vramMB)
        }

        // Calculate recommended VRAM
        if totalRAM >= 65536 { // 64GB
            recommendedVRAM = Int(Double(totalRAM) * 0.75)
        } else {
            recommendedVRAM = Int(Double(totalRAM) * 0.66)
        }

        allocatedVRAM = formatBytes(currentVRAM * 1024 * 1024)
        isLoading = false
    }

    func setVRAM(_ megabytes: Int) {
        isLoading = true
        errorMessage = nil

        let task = Process()
        task.launchPath = "/usr/bin/sudo"
        task.arguments = ["sysctl", "iogpu.wired_limit_mb=\(megabytes)"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                currentVRAM = megabytes
                statusMessage = "✓ VRAM set to \(formatBytes(megabytes * 1024 * 1024))"
                errorMessage = nil
            } else {
                errorMessage = "Failed to set VRAM. Check permissions."
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func resetVRAM() {
        setVRAM(0)
        statusMessage = "✓ VRAM reset to default"
    }

    func makeVRAMPersistent(_ megabytes: Int) {
        let commands = [
            "sudo touch /etc/sysctl.conf",
            "sudo chown root:wheel /etc/sysctl.conf",
            "sudo chmod 0644 /etc/sysctl.conf",
            "echo 'iogpu.wired_limit_mb=\(megabytes)' | sudo tee -a /etc/sysctl.conf > /dev/null"
        ]

        for command in commands {
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", command]

            do {
                try task.run()
                task.waitUntilExit()
            } catch {
                errorMessage = "Error making persistent: \(error.localizedDescription)"
                return
            }
        }

        statusMessage = "✓ VRAM setting saved to /etc/sysctl.conf"
    }

    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
