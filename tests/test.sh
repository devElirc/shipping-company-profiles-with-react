#!/bin/bash
set -e

# Check if we're in a valid working directory
if [ "$PWD" = "/" ]; then
  echo "Error: No working directory set. Please set a WORKDIR in your Dockerfile before running this script."
  exit 1
fi

# Install test deps, Playwright system deps, and browser at run time (keeps image small).
cd /tests
npm install
export DEBIAN_FRONTEND=noninteractive
npx playwright install-deps chromium
npx playwright install chromium

APP_EXIT=0
E2E_EXIT=0

cd /app
npm install || APP_EXIT=$?
npm run build || APP_EXIT=$?

cd /tests
npm run test:e2e || E2E_EXIT=$?

# Produce reward file (REQUIRED): pass only if app setup/build and E2E succeed
if [ "$APP_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi

[ "$APP_EXIT" -eq 0 ] && [ "$E2E_EXIT" -eq 0 ]
