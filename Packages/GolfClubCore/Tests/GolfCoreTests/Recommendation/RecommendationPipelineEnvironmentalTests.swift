import XCTest
@testable import GolfCore

final class RecommendationPipelineEnvironmentalTests: XCTestCase {

    func testPipelineResultContainsEnvironmentalAssessment() throws {
        // Arrange minimal RoundContext with inputs sufficient to build an assessment
        let currentPosition = GeoCoordinate(latitude: 0, longitude: 0)
        //let target = GeoCoordinate(latitude: 0.001, longitude: 0)

        
        let club = Club(id: ClubID(), name: "7 Iron", type: .iron, loftDegrees: 34, averageCarryMeters: 140)
        
        let player = Player(name: "Gerard")
        let hole = Hole(number: 1, par: 4, lengthMeters: 145)

      
        let targetLocation = GeoCoordinate(latitude: 145 / 111_320, longitude: 0)
        let target = TargetPoint(location: targetLocation, type: .greenCentre)

        let strategyGeometry = HoleStrategyGeometry(
            holeID: hole.id,
            greenCentre: targetLocation
        )

        let shotPlan = ShotPlan(
            aimPoint: target,
            targetBearingDegrees: 0,
            targetDistanceMeters: 145,
            routeStrategy: .direct,
            riskLevel: .low,
            confidence: 0.9,
            rationale: "Clear direct route."
        )

        let shotContext = ShotContext(
            player: player,
            roundID: RoundID(),
            hole: hole,
            currentPosition: currentPosition,
            playableLie: .fairway,
            courseArea: .fairway,
            availableClubs: [club],
            strategyGeometry: strategyGeometry,
            currentShotPlan: shotPlan
        )
        
        
        // Minimal RecommendationInputs with weather and hole areas
        let weather = WeatherCondition(
            windSpeedKph: 18.0, // ~5 m/s
            windDirectionDegrees: 90,
            temperatureCelsius: 20,
            precipitation: .zero
        )
        
        
        let landingZone = LandingZone(
            centre: targetLocation,
            priority: 10,
            riskRating: 0.10,   // Double between 0 and 1
            label: "Safe"
        )
        
        let lzEval = LandingZoneEvaluation(
            location: landingZone.centre,
            lieQuality: .fairway,
            hazardExposure: 0.0,
            nextShotDistance: 120,         // pick a reasonable estimate
            scoreExpectation: 1.0          // lower is better in your engine’s ranking
        )
       
        let inputs = RecommendationInputs(
            candidateLandingZones: [lzEval],
            holeAreas: [],
            playerPerformance: nil,
            weatherCondition: weather,
            gpsAccuracyMeters: 5
        )

        // Create minimal Course and Round that reference the hole you already made
        let course = Course(
            id: CourseID(),          // or CourseID() depending on your model
            name: "Test Course",
            holes: [hole]              // include the same 'hole' you created above
        )

        // A Round that has the current hole session set to this hole
        var round = Round(
            id: RoundID(),
            playerID: player.id,
            golfClubID: GolfClubID(),
            courseID: course.id
        )
        // If your Round type requires setting currentHoleSession, do so accordingly.
        // Otherwise, ensure the hole context you pass below is consistent with 'hole'.

        // Build a very light HoleContext aligned with your hole/current position
        let holeContext = HoleContext(
            hole: hole,
            shots: [],
            currentLie: .tee,
            remainingDistanceMeters: DistanceCalculator.distanceMeters(
                from: shotContext.currentPosition,
                to: shotContext.strategyGeometry.finalTarget
            ),
            shotsPlayed: 0,
            greenReached: false
        )

        let roundContext = RoundContext(
            round: round,
            player: player,
            course: course,
            hole: holeContext,
            shot: shotContext,
            recommendationInputs: inputs
        )
     

        let pipeline = RecommendationPipeline()

        // Act
        let result = try pipeline.execute(context: roundContext)

        // Assert
        XCTAssertNotNil(result.environmentalAssessment, "EnvironmentalAssessment should be present in pipeline result for audit")
        if let weatherAssessment = result.environmentalAssessment?.weather {
            XCTAssertEqual(weatherAssessment.windSpeedMetersPerSecond, 5.0, accuracy: 0.001)
        } else {
            XCTFail("Expected WeatherAssessment to be present in EnvironmentalAssessment")
        }
    }

    func testCaddyRecommendationEngineCreateOverloadsCompile() {
        // Arrange
        
        let targetLocation = GeoCoordinate(latitude: 0, longitude: 0)
        let target = TargetPoint(location: targetLocation, type: .greenCentre)

        // Provide a concrete landing zone evaluation for the option
        let landingZone = LandingZone(
            centre: targetLocation,
            priority: 1,
            riskRating: 0.0,
            label: "Test LZ"
        )
        let lzEval = LandingZoneEvaluation(
            location: landingZone.centre,
            lieQuality: .fairway,
            hazardExposure: 0.0,
            nextShotDistance: 0,
            scoreExpectation: 0
        )

        let engine = CaddyRecommendationEngine()
        let risk = RiskAssessment(
            riskLevel: .low,
            hazardExposure: 0,
            penaltyProbability: 0,
            recommendation: "No significant hazards",
            confidence: 1.0,
            
        )
        let option = StrategicOption(
            target: targetLocation,
            clubID: ClubID(),
            landingZone: lzEval,
            risk: risk
        )
        let adaptive = AdaptiveTargetAdjustment(
            originalTarget: option.target,
            adjustedTarget: option.target,
            adjustmentMeters: 0,   // single scalar in your model
            reason: "none",
            confidence: 1.0
        )
        let weatherAdj = WeatherAdjustment(
            distanceAdjustmentMeters: 0,
            lateralAdjustmentMeters: 0,        // add this
            explanation: "none",               // and this
            confidence: 1.0
        )

        // Legacy 3-parameter call
        let rec1 = engine.create(
            option: option,
            adaptiveAdjustment: adaptive,
            weatherAdjustment: weatherAdj
        )
        XCTAssertNotNil(rec1.explanation)

        // New 4-parameter call with nil assessment
        let rec2 = engine.create(
            option: option,
            adaptiveAdjustment: adaptive,
            weatherAdjustment: weatherAdj,
            environmentalAssessment: nil   // or a real EnvironmentalAssessment
        )
        XCTAssertNotNil(rec2.explanation)
    }
}

