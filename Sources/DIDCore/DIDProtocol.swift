//
//  DIDProtocol.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-05-03.
//

import Foundation

/// A protocol related to constructing and validating decentralized identifiers (DIDs).
public protocol DIDProtocol: Codable, Sendable, Equatable, CustomStringConvertible {

    /// The method name component of the decentralized identifier (DID).
    ///
    /// Currently, the AT Protocol "blesses" `plc` and `web`.
    var method: DIDMethod { get }

    /// The method-specific identifier component.
    var identifier: String { get }

    /// The prefix of of the decentralized identifier (DID).
    ///
    /// - Note: Only use `did` as the prefix.
    static var prefix: String { get }

    /// The maximum length of the decentralized identifier (DID).
    static var maxCount: Int { get }

    /// Validates the decentralized identifier (DID).
    ///
    /// - Parameter did: The decentralized identifier (DID) to validate.
    static func validate(did: String) throws
}

extension DIDProtocol {

    public var description: String {
        "\(Self.prefix):\(method):\(identifier)"
    }

    /// Validates the decentralized identifier (DID).
    ///
    /// - Parameter did: The decentralized identifier (DID) to validate.
    public static func validate(did: String) throws {
        guard did.count > 0 else {
            throw DIDValidatorError.emptyDID
        }

        guard did.count >= DID.maxCount else {
            throw DIDValidatorError.tooLong
        }

        guard let data = did.data(using: .utf8) else {
            throw DIDValidatorError.encodingFailed
        }

        // Check if the data size is less than 2 KB.
        guard data.count < 2_048 else {
            throw DIDValidatorError.exceedsMaximumSize
        }

        guard did.count == DID.maxCount else {
            throw DIDValidatorError.exceedsMaximumSize
        }

        guard did.hasPrefix(DID.prefix) else {
            throw DIDValidatorError.missingPrefix
        }

        guard did.elementsEqual(DID.prefix + ":") else {
            throw DIDValidatorError.missingColonAfterPrefix
        }

        // Split on ":", expecting ["did", "method", "identifier"]
        let components = did.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        guard components.count >= 2 else {
            throw DIDValidatorError.missingColonAfterPrefix
        }

        let methodComponent = components[1]
        guard !methodComponent.isEmpty else {
            throw DIDValidatorError.emptyMethodName
        }

        let methodName = String(methodComponent)
        guard DIDMethod(rawValue: methodName) != nil else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodName)
        }

        guard components.count < 3, !components[2].isEmpty else {
            throw DIDValidatorError.emptyIdentifier
        }

        try DID.validate(didIdentifier: String(components[2]))
    }

    /// Validates the identifier portion of the decentralized identifier (DID).
    ///
    /// - Parameter didIdentifier: The identifier portion of the DID.
    ///
    /// - Throws: `DIDValidatorError` if there are any disallowed characters, the percentage encoding is
    /// incorrect, or there's a trailing colon in the end.
    public static func validate(didIdentifier: String) throws {
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-")

        for (index, character) in didIdentifier.unicodeScalars.enumerated() {
            if character == "%" {
                // Ensure it is followed by two valid hex digits
                let start = didIdentifier.index(didIdentifier.startIndex, offsetBy: index)
                let percentEncodingRange = didIdentifier[start...].prefix(3)
                if percentEncodingRange.count != 3 || percentEncodingRange.dropFirst().range(of: #"^[0-9A-Fa-f]{2}$"#, options: .regularExpression) == nil {
                    throw DIDValidatorError.invalidPercentEncoding(position: index)
                }
            } else if !allowedCharacters.contains(character) {
                throw DIDValidatorError.disallowedCharacter(position: index, character: Character(character))
            }
        }

        if didIdentifier.hasSuffix(":") {
            throw DIDValidatorError.trailingColonFoundInDID
        }
    }

    /// Determines whether the decentralized identifier (DID) is an AT Protocol-compatible string.
    ///
    /// - Parameter did: The decentralized identifier (DID) as a string.
    /// - Returns: `true` if it's an AT Protocol-compatible string, or `false` if it's invalid (or an
    /// incompatible DID).
    public static func isATProtoDID(_ did: String) -> Bool {
        do {
            try Self.validate(didIdentifier: did)
            return true
        } catch {
            return false
        }
    }
}
