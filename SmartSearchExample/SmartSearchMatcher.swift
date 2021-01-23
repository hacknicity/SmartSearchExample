//
//  SmartSearchMatcher.swift
//  SmartSearchExample
//
//  Created by Geoff Hackworth on 23/01/2021.
//

import Foundation

/// Search string matcher using token prefixes.
struct SmartSearchMatcher {

    /// Creates a new instance for testing matches against `searchString`.
    public init(searchString: String) {
        // Split `searchString` into tokens by whitespace and sort them by decreasing length
        searchTokens = searchString.split(whereSeparator: { $0.isWhitespace }).sorted { $0.count > $1.count }
    }

    /// Check if `candidateString` matches `searchString`.
    func matches(_ candidateString: String) -> Bool {
        // If there are no search tokens, everything matches
        guard !searchTokens.isEmpty else { return true }

        // Split `candidateString` into tokens by whitespace
        var candidateStringTokens = candidateString.split(whereSeparator: { $0.isWhitespace })

        // Iterate over each search token
        for searchToken in searchTokens {
            // We haven't matched this search token yet
            var matchedSearchToken = false

            // Iterate over each candidate string token
            for (candidateStringTokenIndex, candidateStringToken) in candidateStringTokens.enumerated() {
                // Does `candidateStringToken` start with `searchToken`?
                if let range = candidateStringToken.range(of: searchToken, options: [.caseInsensitive, .diacriticInsensitive]),
                   range.lowerBound == candidateStringToken.startIndex {
                    matchedSearchToken = true

                    // Remove the candidateStringToken so we don't match it again against a different searchToken.
                    // Since we sorted the searchTokens by decreasing length, this ensures that searchTokens that
                    // are equal or prefixes of each other don't repeatedly match the same `candidateStringToken`.
                    // I.e. the longest matches are "consumed" so they don't match again. Thus "c c" does not match
                    // a string unless there are at least two words beginning with "c", and "b ba" will match
                    // "Bill Bailey" but not "Barry Took"
                    candidateStringTokens.remove(at: candidateStringTokenIndex)

                    // Check the next candidate string token
                    break
                }
            }

            // If we failed to match `searchToken` against the candidate string tokens, there is no match
            guard matchedSearchToken else { return false }
        }

        // If we match every `searchToken` against the candidate string tokens, `candidateString` is a match
        return true
    }

    private(set) var searchTokens: [String.SubSequence]
}
