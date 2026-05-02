import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: VRAMViewModel
    @State private var inputValue: String = ""
    @State private var showAdvanced: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("VRAM Tuner")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Text("Optimize GPU memory allocation for local LLMs on macOS")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)

            // Status Cards
            HStack(spacing: 12) {
                StatusCard(
                    title: "Total RAM",
                    value: formatBytes(viewModel.totalRAM * 1024 * 1024),
                    subtitle: "\(viewModel.totalRAM) MB"
                )

                StatusCard(
                    title: "Current VRAM",
                    value: formatBytes(viewModel.currentVRAM * 1024 * 1024),
                    subtitle: viewModel.currentVRAM == 0 ? "Default" : "\(viewModel.currentVRAM) MB"
                )

                StatusCard(
                    title: "Recommended",
                    value: formatBytes(viewModel.recommendedVRAM * 1024 * 1024),
                    subtitle: "\(viewModel.recommendedVRAM) MB"
                )
            }

            // Control Section
            VStack(spacing: 16) {
                // Current Status
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Allocation")
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack {
                        Image(systemName: "gpu")
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text(viewModel.allocatedVRAM)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)

                            if viewModel.currentVRAM == 0 {
                                Text("Using system default allocation")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }

                // Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Set Custom VRAM (in MB)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack(spacing: 12) {
                        TextField("Enter MB value", text: $inputValue)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))

                        Button(action: { applyCustomVRAM() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Apply")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(6)
                        }
                        .disabled(inputValue.isEmpty || viewModel.isLoading)
                    }

                    // Helper Buttons
                    VStack(spacing: 8) {
                        Button(action: { inputValue = String(viewModel.recommendedVRAM) }) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                Text("Use Recommended (\(viewModel.recommendedVRAM) MB)")
                                Spacer()
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(6)
                        }

                        HStack(spacing: 8) {
                            Button(action: { resetVRAM() }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Reset to Default")
                                    Spacer()
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red.opacity(0.3))
                                .cornerRadius(6)
                            }

                            Button(action: { toggleAdvanced() }) {
                                HStack {
                                    Image(systemName: "gearshape.fill")
                                    Text("Advanced")
                                    Spacer()
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.purple.opacity(0.3))
                                .cornerRadius(6)
                            }
                        }
                    }
                }

                // Advanced Options
                if showAdvanced {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()

                        Text("Advanced Options")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .textCase(.uppercase)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("CPU Reserve (MB):")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("", value: $viewModel.CPUReserve, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.caption)

                                Spacer()
                            }

                            Button(action: {
                                let allocate = viewModel.totalRAM - viewModel.CPUReserve
                                inputValue = String(allocate)
                            }) {
                                HStack {
                                    Image(systemName: "calculator")
                                    Text("Calculate (\(viewModel.totalRAM - viewModel.CPUReserve) MB)")
                                    Spacer()
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.orange.opacity(0.3))
                                .cornerRadius(6)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Make Persistent")
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack {
                                Button(action: {
                                    if !inputValue.isEmpty, let value = Int(inputValue) {
                                        viewModel.makeVRAMPersistent(value)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                        Text("Save to /etc/sysctl.conf")
                                        Spacer()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.indigo.opacity(0.3))
                                    .cornerRadius(6)
                                }
                                .disabled(inputValue.isEmpty || viewModel.isLoading)

                                Spacer()
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }

                // Messages
                if !viewModel.statusMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)

                        Text(viewModel.statusMessage)
                            .font(.caption)
                            .foregroundColor(.green)

                        Spacer()
                    }
                    .padding(10)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
                }

                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)

                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)

                        Spacer()
                    }
                    .padding(10)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
            }

            // Info Section
            VStack(alignment: .leading, spacing: 8) {
                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Label("Default allocations:", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("< 64GB RAM")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text("~66%")
                                .font(.caption)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(">= 64GB RAM")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text("~75%")
                                .font(.caption)
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }
                }
                .padding(10)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)

                Text("⚠️ Requires sudo. Changes revert after restart unless made persistent.")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }

            Spacer()
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 600)
        .background(Color(.windowBackgroundColor))
        .onAppear {
            viewModel.refreshVRAM()
        }
    }

    private func applyCustomVRAM() {
        if let value = Int(inputValue) {
            viewModel.setVRAM(value)
            inputValue = ""
        }
    }

    private func resetVRAM() {
        viewModel.resetVRAM()
        inputValue = ""
    }

    private func toggleAdvanced() {
        withAnimation {
            showAdvanced.toggle()
        }
    }

    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.system(.body, design: .default))
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
        .environmentObject(VRAMViewModel())
}
