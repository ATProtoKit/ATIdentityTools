//
//  DIDPLCResolver.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-21.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A concrete implementation for resolving `did:plc` DID documents.
public struct DIDPLCResolver: DIDDocumentResolverProtocol, Sendable {

    /// The URL of the `did:plc`.
    public let plcURL: String

    /// The time the request can take before it times out, in seconds.
    public let timeout: Int

    /// A cache related to decentralized identifiers (DIDs). Optional.
    public var didCache: DIDCache?

    /// The URL session instances used for requests.
    private let urlSession: URLSession

    /// Initializes a new instance of `DIDPLCResolver`.
    ///
    /// - Parameters:
    ///   - plcURL: The URL of the `did:plc`.
    ///   - timeout: The time the request can take before it times out, in milliseconds. Defaults to `3000`
    ///   (equivalent to 3 seconds).
    ///   - didCache: A cache related to decentralized identifiers (DIDs). Optional. Defaults to `nil`.
    ///   - urlSession: The URL session instances used for requests. Defaults to `.shared`.
    public init(plcURL: String, timeout: Int = 3_000, didCache: DIDCache? = nil, urlSession: URLSession = .shared) {
        self.plcURL = plcURL
        self.timeout = timeout
        self.didCache = didCache
        self.urlSession = urlSession
    }

    public func resolveRawDIDDocument(did: String) async throws -> String {
        try await DIDUtilities.timed(milliseconds: UInt64(self.timeout)) {
            guard let plcHost = URL(string: plcURL), let url = URL(string: did.encodedForURIComponent, relativeTo: plcHost) else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.setValue("application/did+ld+json,application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"

            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            switch httpResponse.statusCode {
                case 200:
                    guard let responseString = String(data: data, encoding: .utf8) else {
                        throw URLError(.badServerResponse)
                    }

                    return responseString
                default:
                    throw DIDResolverError.requestFailed(
                        resolver: "DIDPLCResolver",
                        code: httpResponse.statusCode,
                        message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    )
            }
        }
    }
}
