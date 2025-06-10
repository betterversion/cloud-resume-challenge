const { defineConfig } = require("cypress");
const fs = require("fs"); // ⭐ File system operations

module.exports = defineConfig({
  e2e: {
    // Default to staging URL
    baseUrl: "https://test.dzresume.dev",

    // Viewport settings (standard desktop size)
    viewportWidth: 1280,
    viewportHeight: 720,

    // Timeouts
    defaultCommandTimeout: 10000,
    pageLoadTimeout: 30000,
    requestTimeout: 15000,

    // 🎥 STORAGE-OPTIMIZED MEDIA SETTINGS
    video: true,
    videoCompression: 32,
    screenshotOnRunFailure: true,
    screenshotsFolder: "cypress/screenshots",
    videosFolder: "cypress/videos",
    trashAssetsBeforeRuns: true,

    // Test file patterns
    specPattern: "cypress/e2e/**/*.cy.{js,jsx,ts,tsx}",

    setupNodeEvents(on, config) {
      // Log which environment we're testing
      console.log(`🎯 Cypress configured for: ${config.baseUrl}`);

      return config;
    },
  },
});
