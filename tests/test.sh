#!/usr/bin/env bash
set -u

mkdir -p /logs/verifier

TEST_DEPS_EXIT=0
APP_EXIT=0
E2E_EXIT=0
SCRIPT_EXIT=0

# Check if we're in a valid working directory
if [ "$PWD" = "/" ]; then
  echo "Error: No working directory set. Please set a WORKDIR in your Dockerfile before running this script."
  SCRIPT_EXIT=1
fi

# Install the verifier's test dependencies from the exact versions pinned in
# tests/package.json. This avoids brittle lockfile integrity mismatches across
# container environments while still keeping Playwright pinned to 1.49.0.
if [ "$SCRIPT_EXIT" -eq 0 ]; then
  cd /tests
  echo "Installing verifier dependencies..."
  npm install --no-audit --no-fund || TEST_DEPS_EXIT=$?
  export DEBIAN_FRONTEND=noninteractive
fi

# Use the lockfile-pinned Playwright 1.49.0 binary. This installs only the
# Chromium browser and host libraries needed by the visible E2E assertions.
if [ "$TEST_DEPS_EXIT" -eq 0 ]; then
  ./node_modules/.bin/playwright install-deps chromium || TEST_DEPS_EXIT=$?
  ./node_modules/.bin/playwright install chromium || TEST_DEPS_EXIT=$?
fi

if [ "$SCRIPT_EXIT" -eq 0 ]; then
  cd /app
  echo "Installing app dependencies..."
  npm install || APP_EXIT=$?
  echo "Building app..."
  npm run build || APP_EXIT=$?
fi

if [ "$SCRIPT_EXIT" -eq 0 ]; then
  cd /tests
fi
# Run the Playwright verifier directly. It verifies:
# - one labelled article per seeded company
# - the seeded /app/src/companyData.js file remains unchanged
# - logo alt text, fallback initials, verified badges, and rating text format
# - hidden rating rows when rating values are missing
# - badge chips, one Trust Score label per card, and metric progressbar ARIA values
# - the app serves successfully via the Vite dev server started by Playwright
# - required CSS hooks plus mobile layout readability checks

if [ "$TEST_DEPS_EXIT" -eq 0 ]; then
  echo "Running end-to-end tests..."
  npm run test:e2e || E2E_EXIT=$?
fi

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
