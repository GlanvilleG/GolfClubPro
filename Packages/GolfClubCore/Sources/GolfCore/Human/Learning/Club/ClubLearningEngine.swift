//
//  ClubLearningEngine.swift
//  GolfClubCore
//
//  Created by Dragon Development on 14/07/2026.
//
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif


public struct ClubLearningEngine:
    Sendable {

    private let configuration:
        LearningConfiguration

    public init(
        configuration:
            LearningConfiguration =
                LearningConfiguration()
    ) {
        self.configuration =
            configuration
    }

    public func updateErrorPatternProfile(
        existing:
            ShotErrorPatternProfile?,
        observation:
            ShotLearningObservation
    ) -> ShotErrorPatternProfile {

        let clubID =
            observation.shot.clubID


        let existingErrors =
            existing?
                .errors
            ?? []


        let observedErrors =
            observation
                .shot
                .feedback?
                .classifiedErrors
            ?? []


        var updatedErrors =
            existingErrors


        for error in observedErrors {

            if let index =
                updatedErrors.firstIndex(
                    where:
                        {
                            $0.error ==
                                error
                        }
                ) {

                let current =
                    updatedErrors[index]

                updatedErrors[index] =
                    ShotErrorFrequency(
                        error:
                            current.error,
                        occurrenceCount:
                            current.occurrenceCount + 1,
                        percentage:
                            0
                    )

            } else {

                updatedErrors.append(
                    ShotErrorFrequency(
                        error:
                            error,
                        occurrenceCount:
                            1,
                        percentage:
                            0
                    )
                )
            }
        }


        let total =
            updatedErrors.reduce(
                0
            ) {
                result,
                item in

                result +
                item.occurrenceCount
            }


        updatedErrors =
            updatedErrors.map {

                ShotErrorFrequency(
                    error:
                        $0.error,
                    occurrenceCount:
                        $0.occurrenceCount,
                    percentage:
                        total > 0
                        ?
                        Double(
                            $0.occurrenceCount
                        )
                        /
                        Double(total)
                        :
                        0
                )
            }


        return ShotErrorPatternProfile(
            clubID:
                clubID,
            sampleCount:
                (existing?.sampleCount ?? 0) + 1,
            errors:
                updatedErrors
        )
    }
    public func updateDispersionProfile(
        existing:
            ShotDispersionProfile?,
        observation:
            ShotLearningObservation
    ) -> ShotDispersionProfile {

        let shot =
            observation.shot

        let existingSamples =
            existing?
                .sampleCount
            ?? 0

        let newSamples =
            existingSamples + 1


        let previousCarry =
            existing?
                .averageCarryMeters
            ?? 0


        let currentCarry =
            observation.actualOutcome.distanceMeters


        let previousBias =
            existing?
                .lateralBiasMeters
            ?? 0


        let currentBias =
            calculateBias(
                observation:
                    observation
            )


        return ShotDispersionProfile(
            clubID:
                shot.clubID,

            sampleCount:
                newSamples,

            averageCarryMeters:
                weightedAverage(
                    previous:
                        previousCarry,
                    previousCount:
                        existingSamples,
                    current:
                        currentCarry
                ),

            lateralBiasMeters:
                weightedAverage(
                    previous:
                        previousBias,
                    previousCount:
                        existingSamples,
                    current:
                        currentBias
                ),

            shotShape:
                existing?
                    .shotShape
                ?? .straight,

            confidence:
                confidence(
                    sampleCount:
                        newSamples
                )
        )
    }


    private func weightedAverage(
        previous:
            Double,
        previousCount:
            Int,
        current:
            Double
    ) -> Double {

        guard previousCount > 0
        else {
            return current
        }

        return (
            previous *
            Double(previousCount)
            +
            current
        )
        /
        Double(previousCount + 1)
    }


    private func confidence(
        sampleCount:
            Int
    ) -> Double {

        min(
            1,
            Double(sampleCount) / 50
        )
    }


    private func calculateBias(
        observation:
            ShotLearningObservation
    ) -> Double {

        guard let start =
                observation.shot.startLocation
        else {
            return 0
        }

        let target =
            observation.plannedOutcome.targetLocation

        let actual =
            observation.actualOutcome.landingLocation


        let targetBearing =
            bearing(
                from:
                    start,
                to:
                    target
            )

        let actualBearing =
            bearing(
                from:
                    start,
                to:
                    actual
            )


        let angleDifference =
            actualBearing -
            targetBearing


        let distance =
            observation.actualOutcome.distanceMeters


        return sin(
            angleDifference *
                .pi /
                180
        )
        *
        distance
    }


    private func bearing(
        from:
            GeoCoordinate,
        to:
            GeoCoordinate
    ) -> Double {

        let latitude1 =
            from.latitude *
            .pi /
            180

        let latitude2 =
            to.latitude *
            .pi /
            180

        let longitudeDelta =
            (
                to.longitude -
                from.longitude
            )
            *
            .pi /
            180


        let y =
            sin(longitudeDelta)
            *
            cos(latitude2)


        let x =
            cos(latitude1)
            *
            sin(latitude2)
            -
            sin(latitude1)
            *
            cos(latitude2)
            *
            cos(longitudeDelta)


        return atan2(
            y,
            x
        )
        *
        180 /
        .pi
    }
}
