//
//  URIFragmentValidator.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-08-29.
//

import Foundation

/// A utility for validating URI fragments.
///
/// - SeeAlso: [RFC 3986][RFC] and
/// the [W3C specification][W3C] in relation to decentralized identifier (DID) fragments.
///
/// [RFC]: https://datatracker.ietf.org/doc/html/rfc3986
/// [W3C]: https://www.w3.org/TR/did-1.0/#dfn-did-fragments
public enum URIFragmentValidator {

    /// Validates whether a given substring of a `String` is a valid URI fragment, according to RFC 3986.
    ///
    /// The method iterates through each Unicode scalar in the specified substring,
    /// ensuring that only allowed characters or valid percent-encoded sequences are present.
    ///
    /// If `endIndex` is `nil`, the method validates until the end of the string.
    ///
    /// - Parameters:
    ///   - value: The full string containing the fragment to validate.
    ///   - startIndex: The starting position (inclusive) of the substring to validate. Defaults to `0`.
    ///   - endIndex: The ending position (exclusive) of the substring to validate. Optional.
    ///   Defaults to `nil`.
    ///
    /// - Returns: `true` if the substring represents a valid fragment according to RFC 3986,
    ///   or `false` if t's invalid.
    public static func isValidFragment(_ value: String, startingAt startIndex: Int = 0, endingAt endIndex: Int? = nil) -> Bool {
        let scalars = Array(value.unicodeScalars)
        let lowerBound = max(0, min(startIndex, scalars.count))
        let upperBound = max(lowerBound, min(endIndex ?? scalars.count, scalars.count))

        var index = lowerBound
        while index < upperBound {
            let code = scalars[index].value

            if (code >= 65 && code <= 90)         // A-Z
                || (code >= 97 && code <= 122)    // a-z
                || (code >= 48 && code <= 57)     // 0-9
                || code == 45                     // -
                || code == 46                     // .
                || code == 95                     // _
                || code == 126 {                  // ~
                continue
            } else if code == 33                  // !
                || code == 36                     // $
                || code == 38                     // &
                || code == 39                     // '
                || code == 40                     // (
                || code == 41                     // )
                || code == 42                     // *
                || code == 43                     // +
                || code == 44                     // ,
                || code == 59                     // ;
                || code == 61                     // =
            {
                continue
            } else if code == 58                  // :
                || code == 64 {                   // @
                continue
            } else if code == 47                  // /
                || code == 63 {                   // ?
                continue
            } else if code == 37 {                // %
                if index + 2 >= upperBound {
                    return false
                }

                let firstHexidecimal = scalars[index + 1].value
                let secondHexidecimal = scalars[index + 2].value

                // Both must be hex digits.
                guard Self.isHexDigit(firstHexidecimal), Self.isHexDigit(secondHexidecimal) else {
                    return false
                }

                index += 2
            } else {
                return false
            }

            index += 1
        }

        return true
    }

    /// Determines whether the hexidecimal value is a digit.
    ///
    /// - Parameter asciiValue: The ASCII value to check.
    /// - Returns: `true` if it's a digit, or `false` if it's not.
    private static func isHexDigit(_ asciiValue: UInt32) -> Bool {
        return (
            asciiValue >= 48 && asciiValue <= 57
            || asciiValue >= 65 && asciiValue <= 70
            || asciiValue >= 97 && asciiValue <= 102
        )
    }
}
