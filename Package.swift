// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VRAMTuner",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VRAMTuner",
            targets: ["VRAMTuner"]
        )
    ],
    targets: [
        .executableTarget(
            name: "VRAMTuner",
            dependencies: [],
            path: "Sources"
        )
    ]
)
