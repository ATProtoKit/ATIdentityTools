<p align="center">
  <img src="https://github.com/ATProtoKit/ATIdentityTools/blob/main/Sources/ATIdentityTools/Documentation.docc/Resources/atidentitytools_icon.png" height="128" alt="An icon for ATIdentityTools, which contains three stacks of rounded rectangles in an isometric top view. At the top stack, there's an icon of a card with lines on the right side to signify information. On the left side, the at symbol is in a thick weight, with a pointed arrow at the tip, is displayed. The three stacks are, from top to bottom, blue, then two shades of purple.">
</p>

<h1 align="center">ATIdentityTools</h1>

<p align="center">Decentralized Identity (DID) utilities for the AT Protocol, written in Swift.</p>

<div align="center">

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FATProtoKit%2FATCryptography%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ATProtoKit/ATCryptography)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FATProtoKit%2FATCryptography%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ATProtoKit/ATCryptography)
[![GitHub Repo stars](https://img.shields.io/github/stars/atprotokit/atidentitytools?style=flat&logo=github)](https://github.com/ATProtoKit/ATIdentityTools)

</div>
<div align="center">

[![Static Badge](https://img.shields.io/badge/Follow-%40cjrriley.com-0073fa?style=flat&logo=bluesky&labelColor=%23151e27&link=https%3A%2F%2Fbsky.app%2Fprofile%2Fcjrriley.com)](https://bsky.app/profile/cjrriley.com)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/masterj93?color=%23cb5f96&link=https%3A%2F%2Fgithub.com%2Fsponsors%2FMasterJ93)](https://github.com/sponsors/MasterJ93)

</div>

ATIdentityTools is a Swift library to utilize identities in the AT Protocol. Given the importance of identities in the protocol, this package is needed to handle them. It includes finding, resolving, and validation for a given identity.

This Swift package handles the following parts with an user account:
- The handle.
- The Decentralized identifier (DID).
- The DID Document.

A child package named _DIDCore_ has additional features specific to DIDs.

This is a lightweight package that shouldn't take much in your project, but its importance shouldn't be understated. This works best with the ATProtoKit family of Swift packages, but you can also use it alongside any ATProto packages unrelated to ATProtoKit.

This package relates to identity resolution and validation. This, and _DIDCore_, are based on the [`identity`](https://github.com/bluesky-social/atproto/tree/main/packages/identity) and [`did`](https://github.com/bluesky-social/atproto/tree/main/packages/did) packages from the official [`atproto`](https://github.com/bluesky-social/atproto) TypeScript repository, respectively.

## Installation
You can use the Swift Package Manager to download and import the library into your project:
```swift
dependencies: [
    .package(url: "https://github.com/ATProtoKit/ATIdentityTools.git", from: "0.1.0")
]
```

Then under `targets`:
```swift
targets: [
    .target(
        // name: "[name of target]",
        dependencies: [
            .product(name: "ATIdentityTools", package: "atidentitytools"),
            .product(name: "DIDCore", package: "didcore")
        ]
    )
]
```

## Requirements
To use ATIdentityTools in your apps, your app should target the specific version numbers:
- **iOS** and **iPadOS** 14 or later.
- **macOS** 13 or later.
- **tvOS** 14 or later.
- **visionOS** 1 or later.
- **watchOS** 9 or later.

For Linux, you need to use Swift 6.0 or later. On Linux, the minimum requirements include:
- **Amazon Linux** 2
- **Debian** 12
- **Fedora** 39
- **Red Hat UBI** 9
- **Ubuntu** 20.04

You can also use this project for any programs you make using Swift and running on **Docker**.

> [!WARNING]
> As of right now, Windows support is theoretically possible, but not has not been tested to work. Contributions and feedback on making it fully compatible for Windows and Windows Server are welcomed. WebAssembly and Android are currently not supported, but will be in the future.

## Submitting Contributions and Feedback
While this project will change significantly, feedback, issues, and contributions are highly welcomed and encouraged. If you'd like to contribute to this project, please be sure to read both the [API Guidelines](https://github.com/ATProtoKit/ATIdentityTools/blob/main/API_GUIDELINES.md) as well as the [Contributor Guidelines](https://github.com/MasterJ93/ATProtoKit/blob/main/CONTRIBUTING.md) before submitting a pull request. Any issues (such as bug reports or feedback) can be submitted in the [Issues](https://github.com/ATProtoKit/ATIdentityTools/issues) tab. Finally, if there are any security vulnerabilities, please read [SECURITY.md](https://github.com/ATProtoKit/ATIdentityTools/blob/main/SECURITY.md) for how to report it.

If you have any questions, you can ask me on Bluesky ([@cjrriley.com](https://bsky.app/profile/cjrriley.com)). And while you're at it, give me a follow! I'm also active on the [Bluesky API Touchers](https://discord.gg/3srmDsHSZJ) Discord server.

## License
This Swift package is using the Apache 2.0 License. Please view [LICENSE.md](https://github.com/ATProtoKit/ATIdentityTools/blob/main/LICENSE.md) for more details.
