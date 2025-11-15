//
//  DIDMethod.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-05-04.
//

import Foundation

/// The method name component of the decentralized identifier (DID).
///
/// Currently, the AT Protocol considers `plc` and `web` as "blessed."
public enum DIDMethod: String, Codable, Sendable, Equatable, CaseIterable {

    /// The `did:plc` method.
    case plc = "plc"

    /// The `did:web` method.
    case web = "web"

    /// A collection of supported `did` "blessed" types.
    public static let didMethods: [any DIDProtocol.Type] = [
        DIDPLCIdentifier.self,
        DIDWebIdentifier.self
    ]
}
