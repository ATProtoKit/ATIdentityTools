//
//  DIDPlcTests.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-05.
//

import Testing
@testable import DIDCore

@Suite
struct `did:plc` {

    @Suite
    struct `Identify did:plc DID` {

        @Test(arguments: DIDs.valid)
        func `Identify all valid did:plc DIDs`(did: String) throws {
            #expect(throws: Never.self, "DID \(did) should be valid.", performing: {
                try DIDPLCIdentifier(did)
            })
        }

        @Test(arguments: zip(DIDs.invalid.keys, DIDs.invalid.values))
        func `Identify all invalid did:plc DIDs`(invalidDID: String, didValidationError: String) throws {
            #expect(throws: DIDValidatorError.self, "did:plc \(invalidDID) should not be valid: \(didValidationError)", performing: {
                try DIDPLCIdentifier(invalidDID)
            })
        }
    }

    @Suite
    struct `Validate did:plc DIDs` {

        @Test(arguments: DIDs.valid)
        func `Validates the valid did:plc DIDs`(did: String) throws {
            #expect(throws: Never.self, "DID \(did) should be valid.", performing: {
                try DIDPLCIdentifier.validate(did: did)
            })
        }

        @Test(arguments: zip(DIDs.invalid.keys, DIDs.invalid.values))
        func `Invalidate invalid did:plc DIDs`(invalidDID: String, didValidationError: String) throws {
            #expect(throws: DIDValidatorError.self, "did:plc \(invalidDID) should not be valid: \(didValidationError)", performing: {
                try DIDPLCIdentifier.validate(did: invalidDID)
            })
        }
    }

    public enum DIDs {
        public static var valid: [String] {
            return [
                "did:plc:l3rouwludahu3ui3bt66mfvj",
                "did:plc:aaaaaaaaaaaaaaaaaaaaaaaa",
                "did:plc:zzzzzzzzzzzzzzzzzzzzzzzz"
            ]
        }

        public static var invalid: [String: String] {
            return [
                "did:plc:l3rouwludahu3ui3bt66mfv0": "Disallowed character '0' in DID at identifier position 31.",
                "did:plc:l3rouwludahu3ui3bt66mfv1": "Disallowed character '1' in DID at identifier position 31.",
                "did:plc:l3rouwludahu3ui3bt66mfv9": "Disallowed character '9' in DID at identifier position 31.",
                "did:plc:l3rouwludahu3ui3bt66mfv": "DID is too short. did:plc DIDs must have the exact size of 32 characters.",
                "did:plc:l3rouwludahu3ui3bt66mfvja": "did:plc is too long. There's a maximum limit of 32 characters.",
                "did:plc:example.com:": "tooShort",
                "did:plc:exam%3Aple.com%3A8080": "DID is too short. did:plc DIDs must have the exact size of 32 characters.",
                "did::l3rouwludahu3ui3bt66mfvj": "DID method name must not be empty.",
                "did:plc:foo.com": "DID is too short. did:plc DIDs must have the exact size of 32 characters.",
                "": "DID is empty.",
                "random-string": "DID requires \'did\' prefix.",
                "did plc": "Missing colon after the \'did\' prefix.",
                "lorem ipsum dolor sit": "DID requires \'did\' prefix."
            ]
        }
    }
}
