// swift-tools-version: 6.0
//   Draft by Gemini 3 Thinking, finished by Dr. Orion Lawlor, 2026-01-15 (Public Domain)
import PackageDescription

let package = Package(
    name: "Graphduino",
    dependencies: [
        .package(url: "https://github.com/STREGAsGate/Raylib", branch: "master"),
        .package(url: "https://github.com/yeokm1/SwiftSerial", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "Graphduino",
            dependencies: [
                .product(name: "Raylib", package: "Raylib"),
                .product(name: "SwiftSerial", package: "SwiftSerial")
            ]
        )
    ]
)
