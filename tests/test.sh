#!/bin/bash
set -e

mkdir -p /logs/verifier

# Check if we're in a valid working directory
if [ "$PWD" = "/" ]; then
  echo "Error: No working directory set. Please set a WORKDIR in your Dockerfile before running this script."
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# Install the verifier's pinned test dependencies from package-lock.json.
cd /tests
npm ci
export DEBIAN_FRONTEND=noninteractive

# Use the lockfile-pinned Playwright 1.49.0 binary. This installs only the
# Chromium browser and host libraries needed by the visible E2E assertions.
npx --no-install playwright install-deps chromium
npx --no-install playwright install chromium

APP_EXIT=0
E2E_EXIT=0

cd /app
npm install || APP_EXIT=$?
npm run build || APP_EXIT=$?

cd /tests
# Run the visible Playwright spec directly. The spec verifies:
# - one labelled article per seeded company
# - logo alt text, fallback initials, verified badges, and rating text format
# - hidden rating rows when rating values are missing
# - badge chips, one Trust Score label, and metric progressbar ARIA values
# - required CSS hooks: @media (max-width: 640px), ring-fill, metric-grow, stripes
npm run test:e2e || E2E_EXIT=$?

# Set the final command status without exiting early under set -e
set +e
if [ "$APP_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]; then
  true
else
  false
fi

if [ $? -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
