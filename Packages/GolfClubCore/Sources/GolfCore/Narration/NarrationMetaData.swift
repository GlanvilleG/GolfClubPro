//
//  NarrationMetaData.swift
//  GolfClubCore
//
//  Created by Dragon Development on 24/07/2026.
//
import Foundation

/// Immutable metadata describing the narration generation context for auditing and reproducibility.
public struct NarrationMetadata: Codable, Hashable, Sendable, Equatable {
    /// A monotonically increasing identifier for the narration template set.
    public let templateVersion: String
    /// An optional identifier describing the measurement/formatting policy used (e.g., "metric:v1").
    public let policyIdentifier: String?
    /// An optional opaque value enabling stable ordering or tie-breaking if needed.
    public let orderingSeed: String?

    public init(templateVersion: String, policyIdentifier: String? = nil, orderingSeed: String? = nil) {
        self.templateVersion = templateVersion
        self.policyIdentifier = policyIdentifier
        self.orderingSeed = orderingSeed
    }
}
