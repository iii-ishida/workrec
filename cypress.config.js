module.exports = {
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    supportFile: false,
    chromeWebSecurity: false
  },
  env: {
    API_ORIGIN: 'http://localhost:8080',
    FIREBASE_AUTH_ORIGIN: 'http://localhost:9099',
  },
};
