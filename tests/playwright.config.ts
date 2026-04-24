import { defineConfig, devices } from "@playwright/test";

/**
 * E2E tests run against the app at /app (served by webServer).
 */
export default defineConfig({
  testDir: ".",
  fullyParallel: true,
  forbidOnly: true,
  retries: 0,
  workers: 1,
  reporter: "list",
  use: {
    baseURL: "http://localhost:3000",
    trace: "off",
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    command: "npm run dev -- --host 0.0.0.0 --port 3000",
    url: "http://localhost:3000",
    reuseExistingServer: false,
    timeout: 30_000,
    cwd: "/app",
  },
});
