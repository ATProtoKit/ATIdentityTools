//
//  DID.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-05-02.
//

import Foundation

/// A representation of a decentralized identifier (DID).
///
/// This structure both constructs and validates the DID.
///
/// - SeeAlso: The [DID Syntax](https://www.w3.org/TR/did-core/#did-syntax) specifications from the W3C.
public struct DID: DIDProtocol {

    /// The method name component of the decentralized identifier (DID).
    ///
    /// Currently, the AT Protocol "blesses" `plc` and `web`.
    public let method: DIDMethod

    /// The method-specific identifier component.
    public let identifier: String

    public var description: String {
        return "\(DID.prefix):\(method.rawValue):\(self.identifier)"
    }

    /// The prefix of of the decentralized identifier (DID).
    public static let prefix = "did"

    /// The maximum length of the decentralized identifier (DID).
    public static let maxCount = 2_048

    /// Initializes a `DID` object by passing the raw string.
    ///
    /// - Parameter didString: The raw decentralized identifier (DID) string.
    public init(_ didString: String) throws {
        try DID.validate(did: didString)

        let components = didString.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)

        let methodString = String(components[1])
        guard let method = DIDMethod(rawValue: methodString) else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodString)
        }

        self.method = method
        self.identifier = String(components[2])
    }

    /// Validates a decentralized identifier (DID) to see if it's validated by AT Protocol standards.
    ///
    /// - Parameter atProtoDID: The DID to validate.
    /// - `true` if it's valid, or `false` if not.
    public static func validate(atProtoDID: String) -> Bool {
        if atProtoDID.starts(with: "did:plc") {
            return DIDPLCIdentifier.isATProtoDID(atProtoDID)
        } else if atProtoDID.starts(with: "did:web") {
            return DIDWebIdentifier.isDIDWeb(atProtoDID)
        } else {
            return false
        }
    }

    /// Checks whether the given string value is a valid AT Protocol audience identifier.
    ///
    /// An audience identifier with respect to an AT Protocol-specific decentralized identifier must have
    /// the form:
    /// - A valid AT Protocol-specific DID (`did:plc` or `did:web`),
    /// - Followed by a single `#` character,
    /// - Followed by a RFC 3986-validated URI fragment.
    ///
    /// Examples of valid ATProtoAudience:
    /// - `did:plc:abc123#session`
    /// - `did:web:example.com#key1`
    ///
    /// Examples of invalid values:
    /// - `did:web:example.com` (Fragment is missing.)
    /// - `not-a-did#fragment` (Not an AT Protocol-specific DID.)
    /// - `did:plc:abc123#frag#extra` (More than one `#` was detected.)
    ///
    /// - Parameter value: The string value to check.
    /// - Returns: `true` if the string is valid, or `false` if not.
    public func isATProtoAudience(value: String) -> Bool {
        guard let firstHashIndex = value.firstIndex(of: "#") else {
            return false
        }

        let nextSearchStart = value.index(after: firstHashIndex)
        if value[nextSearchStart...].contains("#") {
            return false
        }

        let hashOffset = value.distance(from: value.startIndex, to: firstHashIndex) + 1
        let beforeHash = String(value[..<firstHashIndex])

        return URIFragmentValidator.isValidFragment(value, startingAt: hashOffset) && DID.validate(atProtoDID: beforeHash)
    }
}
