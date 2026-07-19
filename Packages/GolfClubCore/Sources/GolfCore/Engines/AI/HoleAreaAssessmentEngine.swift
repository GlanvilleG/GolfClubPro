//
//  HoleAreaAssessmentEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 19/07/2026.
//
import Foundation

public struct HoleAreaAssessmentEngine:
    Sendable {

    private let standardDeviationLimit:
        Double

    private let samplesPerAxis:
        Int

    public init(
        standardDeviationLimit: Double = 3,
        samplesPerAxis: Int = 31
    ) {
        self.standardDeviationLimit =
            max(
                1,
                standardDeviationLimit
            )

        self.samplesPerAxis =
            max(
                5,
                samplesPerAxis
            )
    }

    public func assess(
        areas: [HoleArea],
        shotDispersion: ShotDispersionModel,
        shotBearingDegrees: Double
    ) -> HoleAssessment {

        let candidateAreas =
            filteredAreas(
                areas,
                shotDispersion:
                    shotDispersion
            )

        guard !candidateAreas.isEmpty else {
            return HoleAssessment(
                areas: [],
                overallRisk:
                    .negligible
            )
        }

        let samples =
            generateSamples(
                shotDispersion:
                    shotDispersion,
                shotBearingDegrees:
                    shotBearingDegrees
            )

        let totalWeight =
            samples.reduce(0) {
                $0 + $1.weight
            }

        guard totalWeight > 0 else {
            return HoleAssessment(
                areas: [],
                overallRisk:
                    .negligible
            )
        }

        let assessments =
            candidateAreas.map { area in

                let containedWeight =
                    samples.reduce(0) {
                        partialResult,
                        sample in

                        guard area.contains(
                            sample.coordinate
                        ) else {
                            return partialResult
                        }

                        return partialResult +
                            sample.weight
                    }

                let probability =
                    containedWeight /
                    totalWeight

                return HoleAreaAssessment(
                    area:
                        area,
                    probability:
                        probability,
                    risk:
                        HazardRisk.classify(
                            probability:
                                probability
                        )
                )
            }
            .sorted {
                $0.probability >
                $1.probability
            }

        let overallRisk =
            assessments
                .filter {
                    isAdverse(
                        areaType:
                            $0.area.type
                    )
                }
                .map(\.risk)
                .max() ??
                .negligible

        return HoleAssessment(
            areas:
                assessments,
            overallRisk:
                overallRisk
        )
    }

    private func filteredAreas(
        _ areas: [HoleArea],
        shotDispersion:
            ShotDispersionModel
    ) -> [HoleArea] {

        guard let dispersionBoundingBox =
            dispersionBoundingBox(
                for:
                    shotDispersion
            )
        else {
            return areas
        }

        return areas.filter { area in
            guard let areaBoundingBox =
                area.boundingBox
            else {
                return false
            }

            return areaBoundingBox.intersects(
                dispersionBoundingBox
            )
        }
    }

    private func dispersionBoundingBox(
        for model:
            ShotDispersionModel
    ) -> GeoBoundingBox? {

        let maximumRadiusMeters =
            standardDeviationLimit *
            max(
                model.lateralSigmaMeters,
                model.longitudinalSigmaMeters
            ) +
            max(
                abs(model.lateralBiasMeters),
                abs(model.longitudinalBiasMeters)
            )

        let northCoordinate =
            coordinate(
                from:
                    model.target,
                northMeters:
                    maximumRadiusMeters,
                eastMeters:
                    0
            )

        let southCoordinate =
            coordinate(
                from:
                    model.target,
                northMeters:
                    -maximumRadiusMeters,
                eastMeters:
                    0
            )

        let eastCoordinate =
            coordinate(
                from:
                    model.target,
                northMeters:
                    0,
                eastMeters:
                    maximumRadiusMeters
            )

        let westCoordinate =
            coordinate(
                from:
                    model.target,
                northMeters:
                    0,
                eastMeters:
                    -maximumRadiusMeters
            )

        return GeoBoundingBox(
            coordinates: [
                northCoordinate,
                southCoordinate,
                eastCoordinate,
                westCoordinate
            ]
        )
    }

    private func generateSamples(
        shotDispersion:
            ShotDispersionModel,
        shotBearingDegrees:
            Double
    ) -> [WeightedCoordinate] {

        let lateralSigma =
            max(
                shotDispersion
                    .lateralSigmaMeters,
                0.01
            )

        let longitudinalSigma =
            max(
                shotDispersion
                    .longitudinalSigmaMeters,
                0.01
            )

        let lateralExtent =
            lateralSigma *
            standardDeviationLimit

        let longitudinalExtent =
            longitudinalSigma *
            standardDeviationLimit

        let lateralStep =
            (2 * lateralExtent) /
            Double(samplesPerAxis - 1)

        let longitudinalStep =
            (2 * longitudinalExtent) /
            Double(samplesPerAxis - 1)

        var samples:
            [WeightedCoordinate] = []

        samples.reserveCapacity(
            samplesPerAxis *
            samplesPerAxis
        )

        for lateralIndex in 0..<samplesPerAxis {

            let lateralOffset =
                -lateralExtent +
                Double(lateralIndex) *
                lateralStep

            for longitudinalIndex in 0..<samplesPerAxis {

                let longitudinalOffset =
                    -longitudinalExtent +
                    Double(longitudinalIndex) *
                    longitudinalStep

                let biasedLateralOffset =
                    lateralOffset +
                    shotDispersion
                        .lateralBiasMeters

                let biasedLongitudinalOffset =
                    longitudinalOffset +
                    shotDispersion
                        .longitudinalBiasMeters

                let weight =
                    gaussianWeight(
                        lateralOffset:
                            lateralOffset,
                        longitudinalOffset:
                            longitudinalOffset,
                        lateralSigma:
                            lateralSigma,
                        longitudinalSigma:
                            longitudinalSigma
                    )

                let localOffset =
                    rotate(
                        lateralMeters:
                            biasedLateralOffset,
                        longitudinalMeters:
                            biasedLongitudinalOffset,
                        bearingDegrees:
                            shotBearingDegrees
                    )

                let sampleCoordinate =
                    coordinate(
                        from:
                            shotDispersion.target,
                        northMeters:
                            localOffset.northMeters,
                        eastMeters:
                            localOffset.eastMeters
                    )

                samples.append(
                    WeightedCoordinate(
                        coordinate:
                            sampleCoordinate,
                        weight:
                            weight
                    )
                )
            }
        }

        return samples
    }

    private func gaussianWeight(
        lateralOffset:
            Double,
        longitudinalOffset:
            Double,
        lateralSigma:
            Double,
        longitudinalSigma:
            Double
    ) -> Double {

        let lateralComponent =
            lateralOffset /
            lateralSigma

        let longitudinalComponent =
            longitudinalOffset /
            longitudinalSigma

        return exp(
            -0.5 *
            (
                lateralComponent *
                lateralComponent +
                longitudinalComponent *
                longitudinalComponent
            )
        )
    }

    private func rotate(
        lateralMeters:
            Double,
        longitudinalMeters:
            Double,
        bearingDegrees:
            Double
    ) -> LocalOffset {

        let bearingRadians =
            bearingDegrees *
            .pi /
            180

        let forwardNorth =
            cos(bearingRadians)

        let forwardEast =
            sin(bearingRadians)

        let rightNorth =
            -sin(bearingRadians)

        let rightEast =
            cos(bearingRadians)

        return LocalOffset(
            northMeters:
                longitudinalMeters *
                forwardNorth +
                lateralMeters *
                rightNorth,
            eastMeters:
                longitudinalMeters *
                forwardEast +
                lateralMeters *
                rightEast
        )
    }

    private func coordinate(
        from origin:
            GeoCoordinate,
        northMeters:
            Double,
        eastMeters:
            Double
    ) -> GeoCoordinate {

        let earthRadiusMeters =
            6_371_000.0

        let latitudeRadians =
            origin.latitude *
            .pi /
            180

        let latitudeDelta =
            northMeters /
            earthRadiusMeters

        let longitudeDivisor =
            earthRadiusMeters *
            max(
                cos(latitudeRadians),
                0.000_001
            )

        let longitudeDelta =
            eastMeters /
            longitudeDivisor

        return GeoCoordinate(
            latitude:
                origin.latitude +
                latitudeDelta *
                180 /
                .pi,
            longitude:
                origin.longitude +
                longitudeDelta *
                180 /
                .pi
        )
    }

    private func isAdverse(
        areaType:
            HoleAreaType
    ) -> Bool {
        areaType.isHazard ||
        areaType.requiresRulesRelief ||
        areaType.isSensitiveArea ||
        areaType == .trees
    }
}

private struct WeightedCoordinate:
    Sendable {

    let coordinate:
        GeoCoordinate

    let weight:
        Double
}

private struct LocalOffset:
    Sendable {

    let northMeters:
        Double

    let eastMeters:
        Double
}
