//
//  HandleResolver.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@preconcurrency import AsyncDNSResolver

/// An actor for resolving handles.
public actor HandleResolver: Sendable {

    /// The DNS subdomain used for handle-based discovery in the AT Protocol.
    public static let subdomain = "_atproto"

    /// The prefix indicating a DID record within a DNS TXT entry.
    public static let prefix: String = "did="

    /// The amount of time (in seconds) allowed for the request to run before it times out.
    public let timeout: Int

    /// An array of backup nameservers. Optional.
    public let backupNameservers: [String]?

    /// An array of IP addresses for the backup nameservers. Optional.
    public var backupNameserverIPs: [String]? = []

    /// Initializes an instance of `HandleResolver`.
    ///
    /// - Parameter options: A list of options for resolving handles. Optional. Defaults to `nil`.
    public init(options: HandleResolverOptions? = nil) {
        let timeout = options?.timeout ?? 3
        let backupNameservers = options?.backupNameservers

        self.timeout = timeout
        self.backupNameservers = backupNameservers
    }

    /// Resolves a handle to get a DID Document.
    ///
    /// - Parameter handle: The handle (domain) to resolve.
    /// - Returns: The resolved DID, or `nil` if not found.
    public func resolve(handle: String) async throws -> String? {
        try await withThrowingTaskGroup(of: String?.self) { group in
            // Launch DNS.
            group.addTask { @Sendable in
                try await self.resolveDNS(with: handle)
            }

            // Launch HTTP.
            group.addTask { @Sendable in
                try await self.resolveHTTP(with: handle)
            }

            // Return as soon as one task gives a non-nil result.
            for try await result in group {
                if let found = result {
                    group.cancelAll() // Cancels any unfinished tasks.
                    return found
                }
            }
            // If we get here, both tasks failed.
            return try await resolveDNSBackup(with: handle)
        }
    }

    /// Resolves the DNS with a handle to get the DID Document.
    ///
    /// - Parameter handle: The handle to resolve.
    /// - Returns: The DID Document, or `nil` (if it can't find a valid one).
    private func resolveDNS(with handle: String) async throws -> String? {
        do {
            let chunkedResults = try await Task.detached(priority: .utility) { () throws -> [String] in
                var options = CAresDNSResolver.Options.default
                options.timeoutMillis = Int32(self.timeout * 1_000)
                let resolver = try AsyncDNSResolver(options: options)
                let txtResults = try await resolver.queryTXT(name: "\(Self.subdomain).\(handle)")
                return txtResults.map { $0.txt }
            }.value

            return await self.parseDNSResult(chuckedResult: chunkedResults)
        } catch {
            return nil
        }
    }

    /// Fetches the DID document from the given handle using HTTP.
    ///
    /// - Parameter handle: The andle to resolve.
    /// - Returns: The DID Document, or `nil` (if the fetching fails).
    ///
    /// - Throws: An error if the URL is poorly constructed, or if the resolution fails.
    public func resolveHTTP(with handle: String) async throws -> String? {
        try await DIDUtilities.timed(milliseconds: UInt64(self.timeout)) {
            guard let host = URL(string: "https://\(handle)"),
                  let wellKnownURL = URL(string: "/.well-known/atproto-did", relativeTo: host) else {
                throw URLError(.badURL)
            }

            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = TimeInterval(self.timeout)
            let session = URLSession(configuration: config)

            do {
                let (data, _) = try await session.data(from: wellKnownURL)

                // Convert data to text and get the first non-empty line.
                if let text = String(data: data, encoding: .utf8),
                   let firstLine = text.split(separator: "\n", omittingEmptySubsequences: true).first?.trimmingCharacters(in: .whitespacesAndNewlines),
                   firstLine.hasPrefix("did:") {

                    // Return the DID string if valid.
                    return String(firstLine)
                } else {
                    return nil
                }
            } catch {
                throw error
            }
        }
    }

    /// Resolves a handle using a backup DNS server.
    ///
    /// - Parameter handle: The handle to resolve.
    /// - Returns: A DID Document, or `nil` (if it can't find a valid one).
    public func resolveDNSBackup(with handle: String) async throws -> String? {
        try await DIDUtilities.timed(milliseconds: UInt64(self.timeout)) {
            do {
                var chunkedResults: [String] = []

                let backupIPAddresses = await self.getBackupNameserverIPs()
                guard let backupIPAddresses = backupIPAddresses, backupIPAddresses.count > 0 else {
                    return nil
                }

                var options = CAresDNSResolver.Options.default
                options.servers = backupIPAddresses
                options.timeoutMillis = Int32(self.timeout * 1_000)
                let resolver = try AsyncDNSResolver(options: options)
                let txtResults = try await resolver.queryTXT(name: "\(Self.subdomain).\(handle)")

                for txtResult in txtResults {
                    chunkedResults.append(txtResult.txt)
                }

                return await self.parseDNSResult(chuckedResult: chunkedResults)
            } catch {
                return nil
            }
        }
    }

    /// Parses the results of a DNS TXT record lookup to extract a valid
    /// decentralized identifier (DID) value.
    ///
    /// - Parameter chuckedResult: An array of TXT records.
    /// - Returns: A valid TXT record, which contains a decentralized identifier (DID), or `nil`
    /// (if there is none).
    public func parseDNSResult(chuckedResult: [String]) async -> String? {
        let found = chuckedResult.filter { $0.hasPrefix(Self.prefix) }
        guard found.count == 1 else {
            return nil
        }

        return String(found[0].dropFirst(Self.prefix.count))
    }

    /// Gets or resolves the IP addresses for the backup nameservers.
    ///
    /// - Returns: An array of IP addresses for backup nameservers, or `nil` if no backup nameservers can
    /// be found.
    public func getBackupNameserverIPs() async -> [String]? {
        guard let backupNameservers = self.backupNameservers, !backupNameservers.isEmpty else {
            return backupNameservers
        }

        do {
            var options = CAresDNSResolver.Options.default
            options.timeoutMillis = Int32(self.timeout * 1_000)
            let resolver = try AsyncDNSResolver(options: options)
            var ipAddressResults: [String] = []

            for ipAddress in backupNameservers {
                let recordResult: String

                if ipAddress.contains(".") {
                    recordResult = try await resolver.queryA(name: ipAddress)[0].address.address
                } else if ipAddress.contains(":") {
                    recordResult = try await resolver.queryAAAA(name: ipAddress)[0].address.address
                } else {
                    continue
                }

                ipAddressResults.append(recordResult)
            }

            return self.backupNameserverIPs
        } catch {
            return nil
        }
    }
}
