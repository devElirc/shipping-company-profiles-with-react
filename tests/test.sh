#!/bin/bash
set -e

mkdir -p /logs/verifier

TEST_DEPS_EXIT=0
APP_EXIT=0
E2E_EXIT=0

# Check if we're in a valid working directory
if [ "$PWD" = "/" ]; then
  echo "Error: No working directory set. Please set a WORKDIR in your Dockerfile before running this script."
  exit 1
fi

# Install the verifier's test dependencies. Prefer the tracked lockfile when it
# is present, but fall back to the package.json-pinned version for older task
# bundles that may not yet include tests/package-lock.json.
cd /tests
if [ -f package-lock.json ]; then
  npm ci || TEST_DEPS_EXIT=$?
else
  npm install --no-audit --no-fund || TEST_DEPS_EXIT=$?
fi
export DEBIAN_FRONTEND=noninteractive

# Use the lockfile-pinned Playwright 1.49.0 binary. This installs only the
# Chromium browser and host libraries needed by the visible E2E assertions.
if [ "$TEST_DEPS_EXIT" -eq 0 ]; then
  ./node_modules/.bin/playwright install-deps chromium || TEST_DEPS_EXIT=$?
  ./node_modules/.bin/playwright install chromium || TEST_DEPS_EXIT=$?
fi

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
if [ "$TEST_DEPS_EXIT" -eq 0 ]; then
  npm run test:e2e || E2E_EXIT=$?
fi

set +e
if [ "$TEST_DEPS_EXIT" -eq 0 ] && [ "$APP_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]; then
  true
else
  false
fi

if [ $? -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
