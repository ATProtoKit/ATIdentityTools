//
//  DIDWebTests.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-05.
//

import Testing
@testable import DIDCore

@Suite
struct `did:web` {

    @Suite
    struct `Identify did:web DIDs` {

        @Test(arguments: DIDs.valid)
        func `Identify all valid did:web DIDs`(did: String, entry: String) {
            let isValid = DIDWebIdentifier.isDIDWeb(did)
            #expect(isValid == true, "DID \(did) should be valid.")
        }

        @Test(arguments: zip(DIDs.invalid.keys, DIDs.invalid.values))
        func `Identify all invalid did:web DIDs`(invalidDID: String, didValidationError: String) {
            let isValid = DIDWebIdentifier.isDIDWeb(invalidDID)
            #expect(isValid == false, "DID \(invalidDID) shouldn't be valid.")
        }
    }

    @Suite
    struct `Validate did:web DIDs` {

    }

    public enum DIDs {
        public static var valid: [String: String] {
            return [
                "did:web:example.com": "https://example.com/",
                "did:web:sub.example.com": "https://sub.example.com/",
                "did:web:http://localhost:8080": "https://localhost:8080/"
            ]
        }

        public static var invalid: [String: String] {
            return [
                "did:web:": "DID identifier must not be empty.",
                "did:web:foo@example.com": "Invalid URL: foo@example.com",
                "did:web::example.com": "Method segment cannot start with a colon.",
                "did:web:example.com:": "Method segment cannot start or end with a colon.",
                "did:web:exam%3Aple.com%3A8080": "Invalid URL: exam%3Aple.com%3A8080",
                "": "DID is empty.",
                "random-string": "DID requires 'did' prefix.",
                "did web": "Missing colon after the 'did' prefix.",
                "lorem ipsum dolor sit": "DID requires 'did' prefix."
            ]
        }
    }
}
