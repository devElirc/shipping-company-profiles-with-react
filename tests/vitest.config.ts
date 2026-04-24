import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "jsdom",
    include: ["unit/**/*.spec.jsx"],
    setupFiles: ["./vitest.setup.js"],
    reporters: ["default"],
  },
});
