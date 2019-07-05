// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "KTaskingAPI",
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.7.0")),
      .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.7.1"),
      .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "9.0.0"),
      .package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", from: "2.0.0"),
      .package(url: "https://github.com/IBM-Swift/Health.git", from: "1.0.0"),
      .package(url: "https://github.com/IBM-Swift/Kitura-OpenAPI.git", from: "1.1.1"),
      .package(url: "https://github.com/IBM-Swift/Swift-Kuery-ORM", from: "0.3.1"),
      .package(url: "https://github.com/IBM-Swift/Swift-Kuery-PostgreSQL", from: "1.2.0"),
      .package(url: "https://github.com/IBM-Swift/Swift-JWT.git", from: "3.5.0"),
    ],
    targets: [
      .target(name: "KTaskingAPI", dependencies: [ .target(name: "Application"), "Kitura" , "HeliumLogger"]),
      .target(name: "Application", dependencies: [ 
        "Kitura", "CloudEnvironment","SwiftMetrics", "Health", 
        "KituraOpenAPI", "SwiftKueryPostgreSQL", "SwiftKueryORM", "SwiftJWT"
      ]),

      .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura","HeliumLogger" ])
    ]
)
