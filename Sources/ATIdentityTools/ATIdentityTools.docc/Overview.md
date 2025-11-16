# ``ATIdentityTools``

@Metadata {
    @PageImage(
        purpose: icon, 
        source: "atidentitytools_icon", 
        alt: "A technology icon representing the ATIdentityTools framework.")
    @PageColor(blue)
}

Identify and validate identities in the AT Protocol.

## Overview

ATIdentityTools is a Swift library that manages identities within the AT Protocol. It’s an essential package for handling identities effectively. It provides functionalities for finding, resolving, and validating identities, all while being lightweight and small in your project.

You can use it in ATProtoKit packages or any ATProto packages unrelated to ATProtoKit.

A child package, DIDCore, is also available, which specifically lets you identify and validate decentralized identifiers (DIDs).

## Quick Example

```swift
do {
    let handleResolver = HandleResolver()
    let handleResult = try await handleResolver.resolve(handle: "why.bsky.team")

    var didResolver = DIDResolver()
    let didDocument = try await didResolver.resolve(did: "did:plc:wlef3srsa3hlyzj2hy6yncrh")

    print("Handle resolved to: \(handleResult ?? "nothing.")")
    print("DID Document: \(didDocument)")
} catch {
    print(error)
}
```

ATIdentityTools is fully open source under the [Apache 2.0 license](https://github.com/ATProtoKit/ATIdentityTools/blob/main/LICENSE.md). You can take a look at it and make contributions to it [on GitHub](https://github.com/ATProtoKit/ATIdentityTools).

## Topics

### Resolvers

- ``HandleResolver``
- ``HandleResolverOptions``
- ``DIDResolver``
- ``DIDResolverOptions``
- ``DIDPLCResolver``
- ``DIDWebResolver``
- ``DIDDocumentResolverProtocol``

### Identity Container

- ``ATProtoData``

### Caching

- ``DIDCache``
- ``CacheResult``
- ``MemoryCache``

### Utilities

- ``ATProtocolDataUtilities``
- ``DIDUtilities``

### Error Handing

- ``ATIdentityToolsError``
- ``ATProtoDocumentError``
- ``DIDResolverError``
- ``HandleResolverError``
- ``TimeoutError``
