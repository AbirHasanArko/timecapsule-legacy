// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TimeCapsule",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TimeCapsule",
            targets: ["TimeCapsule"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "TimeCapsule",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk", condition: .when(platforms: [.iOS])),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk", condition: .when(platforms: [.iOS])),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk", condition: .when(platforms: [.iOS]))
            ],
            path: "TimeCapsule",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TimeCapsuleTests",
            dependencies: ["TimeCapsule"],
            path: "TimeCapsuleTests"
        )
    ]
)

