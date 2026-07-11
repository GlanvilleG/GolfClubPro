
GolfCore contains no Apple framework dependencies.

GolfPlatformApple contains adapters that translate Apple framework data into GolfCore domain models.

Application and Watch targets compose these modules and own user-interface and persistence concerns.

Apple adapters must not contain golf-domain decisions.

docs: add ADR for Apple platform integration
feat: add GolfPlatformApple package
refactor: replace CoreLocationService with AppleLocationProvider
test: add Apple location provider tests

1. GolfCore package tests
2. GolfPlatformApple package tests
3. GolfClubPro iPhone target
4. GolfClubProTests
5. GolfClubPro Watch target
6. Full workspace test
