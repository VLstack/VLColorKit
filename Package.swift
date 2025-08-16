// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "VLColorKit",
                      platforms: [ .iOS(.v17), .macOS(.v15) ],
                      products:
                      [
                       .library(name: "VLColorKit",
                                targets: [ "VLColorKit" ])
                      ],
                      targets:
                      [
                       .target(name: "VLColorKit")
                      ])
