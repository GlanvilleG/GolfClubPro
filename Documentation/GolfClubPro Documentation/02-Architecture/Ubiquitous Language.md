|Type| Responsibility| Examples |
| --- | --- | --- |
|**  Entity**|  Has identity and lifecycle| Round, HoleSession, Shot, Player|
|  Value Object|  Immutable descriptive informati| GeoCoordinate, TargetPoint, LandingZone, ClubRecommendation|
| Aggregate |  Consistency boundary|  Round|
| Engine |  Deterministic decision-making|  RoundEngine, RecommendationEngine, StrategyEngine|
| Service |  Domain operation using one or more entities|  LieDetector, GolfClubDetectionService, HoleDetectionService|
|  Provider|  External platform or service adapter|  AppleLocationProvider, AppleMotionProvider|
| Coordinator |  Orchestrates workflows|  RoundOrchestrator, PersistentOfflineRoundCoordinator|
| Repository |  Persistence boundary|  (future) RoundRepository|
| Planner|  Produces a future plan|  RoutePlanner, ShotPlanner|
|  Selector|  Chooses between alternatives|  TargetSelector|
|  Evaluator|  Scores or assesses|  ObstacleEvaluator|
| Mapper |  Converts representations|  (future) CLLocationMapper|
| Factory |  Creates complex objects|  (future if needed)|
