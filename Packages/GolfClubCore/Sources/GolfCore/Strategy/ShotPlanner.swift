//
//  ShotPlanner.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//
import Foundation

public struct ShotPlanner: Sendable {

    public init() {}

    public func makePlan(
        from currentPosition: GeoCoordinate,
        selection: TargetSelection,
        preferredClubID: ClubID? = nil,
        alternativeClubIDs: [ClubID] = []
    ) -> ShotPlan {
        let target = selection.target

        let distance = DistanceCalculator.distanceMeters(
            from: currentPosition,
            to: target.location
        )

        let bearing = bearingDegrees(
            from: currentPosition,
            to: target.location
        )

        let riskLevel = riskLevel(
            for: selection.obstacleEvaluation.riskScore
        )

        let confidence = confidence(
            routeRisk: selection.route.estimatedRisk,
            obstacleRisk: selection.obstacleEvaluation.riskScore
        )

        return ShotPlan(
            aimPoint: target,
            targetBearingDegrees: bearing,
            targetDistanceMeters: distance,
            preferredClubID: preferredClubID,
            alternativeClubIDs: alternativeClubIDs,
            routeStrategy: selection.route.strategy,
            riskLevel: riskLevel,
            confidence: confidence,
            rationale: makeRationale(for: selection)
        )
    }

    private func bearingDegrees(
        from start: GeoCoordinate,
        to end: GeoCoordinate
    ) -> Double {
        let startLatitude = start.latitude * .pi / 180
        let endLatitude = end.latitude * .pi / 180
        let longitudeDelta =
            (end.longitude - start.longitude) * .pi / 180

        let y = sin(longitudeDelta) * cos(endLatitude)

        let x =
            cos(startLatitude) * sin(endLatitude) -
            sin(startLatitude) *
            cos(endLatitude) *
            cos(longitudeDelta)

        let bearing = atan2(y, x) * 180 / .pi

        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    private func riskLevel(
        for riskScore: Double
    ) -> ShotRiskLevel {
        switch riskScore {
        case ..<0.20:
            return .low
        case 0.20..<0.45:
            return .moderate
        case 0.45..<0.75:
            return .high
        default:
            return .extreme
        }
    }

    private func confidence(
        routeRisk: Double,
        obstacleRisk: Double
    ) -> Double {
        let combinedRisk = min(
            1,
            max(0, routeRisk + obstacleRisk)
        )

        return max(0, 1 - combinedRisk)
    }

    private func makeRationale(
        for selection: TargetSelection
    ) -> String {
        let routeReason = selection.route.rationale
        let obstacleReason =
            selection.obstacleEvaluation.rationale

        return "\(routeReason) \(obstacleReason)"
    }
}
