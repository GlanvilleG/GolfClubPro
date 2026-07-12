#
//  check_architecture_boundaries.sh
//  GolfClubPro
//
//  Created by Dragon Development on 13/07/2026.
//
#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GOLF_CORE_DIR="$ROOT_DIR/Packages/GolfClubCore/Sources/GolfCore"
APPLE_PLATFORM_DIR="$ROOT_DIR/Packages/GolfPlatformApple/Sources/GolfPlatformApple"

failed=0

check_forbidden_imports() {
    local directory="$1"
    shift
    local imports=("$@")

    for framework in "${imports[@]}"; do
        if grep -R \
            --include="*.swift" \
            -n "import ${framework}" \
            "$directory" >/dev/null 2>&1; then

            echo "ERROR: Forbidden import '${framework}' found in:"
            grep -R \
                --include="*.swift" \
                -n "import ${framework}" \
                "$directory"

            failed=1
        fi
    done
}
echo "Dragon Dev Boundry Check (Version 1.01)"
echo "Checking GolfCore boundaries..."

check_forbidden_imports \
    "$GOLF_CORE_DIR" \
    SwiftUI \
    SwiftData \
    CoreLocation \
    CoreMotion \
    WatchConnectivity \
    WeatherKit \
    HealthKit \
    Speech \
    MapKit \
    UIKit \
    AppKit \
    CloudKit

echo "Checking GolfPlatformApple boundaries..."

check_forbidden_imports \
    "$APPLE_PLATFORM_DIR" \
    SwiftUI \
    SwiftData

if grep -R \
    --include="*.swift" \
    -n "import GolfPlatformApple" \
    "$GOLF_CORE_DIR" >/dev/null 2>&1; then

    echo "ERROR: GolfCore must not depend on GolfPlatformApple."
    grep -R \
        --include="*.swift" \
        -n "import GolfPlatformApple" \
        "$GOLF_CORE_DIR"

    failed=1
fi

if [ "$failed" -ne 0 ]; then
    echo "Architecture boundary check failed."
    exit 1
fi

echo "Architecture boundary check passed."
