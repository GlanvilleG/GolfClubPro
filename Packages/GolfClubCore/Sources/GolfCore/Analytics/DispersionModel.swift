//
//  DispersionModel.swift
//  GolfCore
//
//  Created by Dragon Development on 10/07/2026.
//

import Foundation

public enum DirectionalTendency:
    String,
    Codable,
    CaseIterable,
    Sendable {

    case left
    case centred
    case right
    case insufficientData
}

public struct ClubDispersionSummary:
    Codable,
    Equatable,
    Sendable {

    public var clubID: ClubID
    public var sampleSize: Int
    public var directionalSampleSize: Int

    public var averageDistanceMeters: Double?
    public var distanceStandardDeviationMeters: Double?

    /// Negative values indicate an average miss left.
    /// Positive values indicate an average miss right.
    public var averageDirectionalErrorDegrees: Double?

    public var meanAbsoluteDirectionalErrorDegrees: Double?
    public var leftMissPercentage: Double?
    public var rightMissPercentage: Double?
    public var centredPercentage: Double?

    public var directionalTendency: DirectionalTendency

    public init(
        clubID: ClubID,
        sampleSize: Int,
        directionalSampleSize: Int,
        averageDistanceMeters: Double?,
        distanceStandardDeviationMeters: Double?,
        averageDirectionalErrorDegrees: Double?,
        meanAbsoluteDirectionalErrorDegrees: Double?,
        leftMissPercentage: Double?,
        rightMissPercentage: Double?,
        centredPercentage: Double?,
        directionalTendency: DirectionalTendency
    ) {
        self.clubID = clubID
        self.sampleSize = sampleSize
        self.directionalSampleSize = directionalSampleSize
        self.averageDistanceMeters = averageDistanceMeters
        self.distanceStandardDeviationMeters =
            distanceStandardDeviationMeters
        self.averageDirectionalErrorDegrees =
            averageDirectionalErrorDegrees
        self.meanAbsoluteDirectionalErrorDegrees =
            meanAbsoluteDirectionalErrorDegrees
        self.leftMissPercentage = leftMissPercentage
        self.rightMissPercentage = rightMissPercentage
        self.centredPercentage = centredPercentage
        self.directionalTendency = directionalTendency
    }
}

public struct DispersionModel: Sendable {

    public init() {}

    public func makeSummary(
        for clubID: ClubID,
        from shots: [Shot],
        maximumShots: Int = 30,
        centredToleranceDegrees: Double = 2
    ) -> ClubDispersionSummary {
        let selectedShots = shots
            .filter {
                $0.clubID == clubID &&
                $0.completedAt != nil
            }
            .sorted {
                ($0.completedAt ?? $0.startedAt) >
                ($1.completedAt ?? $1.startedAt)
            }
            .prefix(max(1, maximumShots))

        let shotsArray = Array(selectedShots)
        let distances = shotsArray.compactMap(\.distanceMeters)

        let directionalErrors = shotsArray.compactMap {
            directionalErrorDegrees(for: $0)
        }

        let averageDistance = mean(distances)
        let distanceDeviation = standardDeviation(distances)

        let averageDirectionalError = mean(directionalErrors)
        let absoluteDirectionalError =
            mean(directionalErrors.map(abs))

        let directionCounts = countDirections(
            directionalErrors,
            centredToleranceDegrees: centredToleranceDegrees
        )

        let directionalCount = directionalErrors.count

        return ClubDispersionSummary(
            clubID: clubID,
            sampleSize: shotsArray.count,
            directionalSampleSize: directionalCount,
            averageDistanceMeters: averageDistance,
            distanceStandardDeviationMeters: distanceDeviation,
            averageDirectionalErrorDegrees:
                averageDirectionalError,
            meanAbsoluteDirectionalErrorDegrees:
                absoluteDirectionalError,
            leftMissPercentage: percentage(
                directionCounts.left,
                of: directionalCount
            ),
            rightMissPercentage: percentage(
                directionCounts.right,
                of: directionalCount
            ),
            centredPercentage: percentage(
                directionCounts.centred,
                of: directionalCount
            ),
            directionalTendency: tendency(
                averageErrorDegrees: averageDirectionalError,
                directionalSampleSize: directionalCount,
                centredToleranceDegrees: centredToleranceDegrees
            )
        )
    }

    public func makeSummaries(
        from shots: [Shot],
        maximumShotsPerClub: Int = 30
    ) -> [ClubDispersionSummary] {
        let clubIDs = Set(shots.map(\.clubID))

        return clubIDs
            .map {
                makeSummary(
                    for: $0,
                    from: shots,
                    maximumShots: maximumShotsPerClub
                )
            }
            .sorted {
                $0.clubID.value.uuidString <
                $1.clubID.value.uuidString
            }
    }

    private func directionalErrorDegrees(
        for shot: Shot
    ) -> Double? {
        guard
            let start = shot.startLocation,
            let end = shot.endLocation,
            let plannedBearing = shot.plannedBearingDegrees
        else {
            return nil
        }

        let actualBearing = bearingDegrees(
            from: start,
            to: end
        )

        return angularDifferenceDegrees(
            planned: plannedBearing,
            actual: actualBearing
        )
    }

    private func bearingDegrees(
        from start: GeoCoordinate,
        to end: GeoCoordinate
    ) -> Double {
        let startLatitude = start.latitude * .pi / 180
        let endLatitude = end.latitude * .pi / 180

        let longitudeDelta =
            (end.longitude - start.longitude) *
            .pi / 180

        let y =
            sin(longitudeDelta) *
            cos(endLatitude)

        let x =
            cos(startLatitude) *
            sin(endLatitude) -
            sin(startLatitude) *
            cos(endLatitude) *
            cos(longitudeDelta)

        let bearing =
            atan2(y, x) * 180 / .pi

        return (bearing + 360)
            .truncatingRemainder(dividingBy: 360)
    }

    private func angularDifferenceDegrees(
        planned: Double,
        actual: Double
    ) -> Double {
        var difference =
            (actual - planned)
                .truncatingRemainder(dividingBy: 360)

        if difference > 180 {
            difference -= 360
        }

        if difference < -180 {
            difference += 360
        }

        return difference
    }

    private func mean(
        _ values: [Double]
    ) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +) /
            Double(values.count)
    }

    private func standardDeviation(
        _ values: [Double]
    ) -> Double? {
        guard
            values.count > 1,
            let average = mean(values)
        else {
            return nil
        }

        let variance =
            values
                .map {
                    let difference = $0 - average
                    return difference * difference
                }
                .reduce(0, +) /
                Double(values.count)

        return sqrt(variance)
    }

    private func countDirections(
        _ errors: [Double],
        centredToleranceDegrees: Double
    ) -> (
        left: Int,
        centred: Int,
        right: Int
    ) {
        var left = 0
        var centred = 0
        var right = 0

        for error in errors {
            if error < -centredToleranceDegrees {
                left += 1
            } else if error > centredToleranceDegrees {
                right += 1
            } else {
                centred += 1
            }
        }

        return (left, centred, right)
    }

    private func percentage(
        _ count: Int,
        of total: Int
    ) -> Double? {
        guard total > 0 else {
            return nil
        }

        return Double(count) /
            Double(total) * 100
    }

    private func tendency(
        averageErrorDegrees: Double?,
        directionalSampleSize: Int,
        centredToleranceDegrees: Double
    ) -> DirectionalTendency {
        guard
            directionalSampleSize >= 3,
            let averageErrorDegrees
        else {
            return .insufficientData
        }

        if averageErrorDegrees <
            -centredToleranceDegrees {
            return .left
        }

        if averageErrorDegrees >
            centredToleranceDegrees {
            return .right
        }

        return .centred
    }
}
